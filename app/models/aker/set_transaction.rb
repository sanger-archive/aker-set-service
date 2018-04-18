class Aker::SetTransaction < ApplicationRecord
  belongs_to :aker_set, class_name: "Aker::Set", optional: true

  has_many :materials, class_name: "Aker::SetTransactionMaterial", foreign_key: :aker_set_transaction_id, dependent: :destroy

  validate :check_set_name_on_create_operation, if: :is_create_transaction?

  def check_set_name_on_create_operation
    errors.add(:set_name, 'Set name is nil') if set_name.nil?
    errors.add(:set_name, 'You cannot define set id and set name in the same transaction operation') if aker_set_id
    errors.add(:set_name, 'There is already another set with the same name') if Aker::Set.find_by(name: set_name)
  end

  def is_create_transaction?
    operation == 'create'
  end


  def apply_materials_in_transaction!
    transaction_materials = Aker::SetTransactionMaterial.where(aker_set_transaction_id: id)

    ActiveRecord::Base.transaction do
      if operation == 'create'
        created_set = Aker::Set.create!(name: set_name, locked: false, owner_id: owner_id)
        aker_set_id = created_set.id
      end

      if !aker_set_id
        aker_set_id = aker_set.id
      end

      transaction_materials.in_batches(of: batch_size) do |group|
        if ((operation == 'add') || (operation == 'create'))
          data = group.map do |transaction_material| 
            { 
              aker_material_id: transaction_material.aker_set_material_id, 
              aker_set_id: aker_set_id
            } 
          end          
          Aker::SetMaterial.bulk_insert(values: data)
        elsif operation == 'remove'
          if aker_set_id
            Aker::SetMaterial.where(aker_set_id: aker_set_id, aker_material_id: group.pluck(:aker_set_material_id)).delete_all
          end
        end
      end

      # If applied right, we remove the transactional materials to free space. We could leave them if we wanted
      transaction_materials.delete_all
    end
  end

  def done?
    status == 'done'
  end
end
