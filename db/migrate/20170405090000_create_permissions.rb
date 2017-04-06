class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.references :accessible, polymorphic: true, type: :uuid

      t.references :permittable, polymorphic: true

      t.boolean :r, default: false
      t.boolean :w, default: false
      t.boolean :x, default: false

      t.timestamps
    end

  end
end
