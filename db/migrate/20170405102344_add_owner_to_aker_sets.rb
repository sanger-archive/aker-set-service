class AddOwnerToAkerSets < ActiveRecord::Migration[5.0]
  def change
    add_column :aker_sets, :owner_id, :string
  end
end
