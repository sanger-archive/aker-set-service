class ChangeSetNameToBeCaseInsensitive < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'citext'
    change_column :aker_sets, :name, :citext
    add_index :aker_sets, :name, unique: true
  end
  def down
    remove_index :aker_sets, :name
    change_column :aker_sets, :name, :text
  end
end
