class CreateAkerSetMaterials < ActiveRecord::Migration[5.0]
  def change
    create_table :aker_set_materials do |t|
      t.references :aker_set, foreign_key: true, type: :uuid
      t.references :aker_material, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
