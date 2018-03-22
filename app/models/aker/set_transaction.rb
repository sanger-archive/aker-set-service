class Aker::SetTransaction < ApplicationRecord
  belongs_to :aker_set, class_name: "Aker::Set"

  has_many :materials, class_name: "Aker::SetTransactionMaterial", foreign_key: :aker_set_transaction_id, dependent: :destroy


  def apply_materials_in_transaction!
    transaction_materials = Aker::SetTransactionMaterial.where(aker_set_transaction_id: id)

    ActiveRecord::Base.transaction do
      transaction_materials.in_batches(of: batch_size) do |group|
        if operation == 'add'
          data = group.map do |transaction_material| 
            { 
              aker_material_id: transaction_material.aker_set_material_id, 
              aker_set_id: aker_set.id 
            } 
          end          
          Aker::SetMaterial.bulk_insert(values: data)
        elsif operation == 'remove'
          Aker::SetMaterial.where(aker_material_id: group.pluck(:aker_set_material_id)).delete_all
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
