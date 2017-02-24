class AddLockedBooleanToAkerSets < ActiveRecord::Migration[5.0]
  def change
    add_column :aker_sets, :locked, :boolean, null: false, default: false
  end
end
