class PermissionTableChanges < ActiveRecord::Migration[5.0]
  def change
    ActiveRecord::Base.transaction do |t|
      add_column :permissions, :permission_type, :string, null: true
    end

    change_column :permissions, :permission_type, :string, null: false

    remove_column :permissions, :r
    remove_column :permissions, :w
    remove_column :permissions, :x

    add_index :permissions, [:permitted, :permission_type, :accessible_id, :accessible_type ], unique: true, name: :index_permissions_on_various
  end
end
