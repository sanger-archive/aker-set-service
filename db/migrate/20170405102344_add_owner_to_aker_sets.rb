class AddOwnerToAkerSets < ActiveRecord::Migration[5.0]
  def change
    add_column :aker_sets, :owner_id, :integer
    add_foreign_key :aker_sets, :users, column: :owner_id, primary_key: :id
  end
end
