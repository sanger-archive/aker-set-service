class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.references :accessible, polymorphic: true
      t.string :permitted
      t.integer :permissions_mask

      t.timestamps
    end
  end
end
