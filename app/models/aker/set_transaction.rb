class Aker::SetTransaction < ApplicationRecord
  belongs_to :aker_set, class_name: "Aker::Set"


  has_many :materials, class_name: "Aker::SetTransactionMaterial", foreign_key: :aker_set_transaction_id


  def apply_materials_in_transaction!
    transaction_materials = Aker::SetTransactionMaterial.where(aker_set_transaction_id: id).select(:aker_set_material_id)

    ActiveRecord::Base.transaction do
      transaction_materials.in_batches do |group|
        data = group.map do |transaction_material| 
          { 
            aker_material_id: transaction_material.aker_set_material_id, 
            aker_set_id: aker_set.id 
          } 
        end
        if operation == 'add'
          Aker::SetMaterial.bulk_insert(values: data)
        end
      end
    end
  end
end
