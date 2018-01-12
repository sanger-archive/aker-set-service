class RemoveDefaultUuidFromMaterials < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:aker_materials, :id, nil)
  end
end
