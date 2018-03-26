class AddSetTransactionTables < ActiveRecord::Migration[5.0]
  def change
    ActiveRecord::Base.transaction do |t|
      create_table :aker_set_transactions do |t|
        t.text :status
        t.integer :batch_size, default: 1000
        t.text :operation, null: true
        t.string :owner_id
        t.references :aker_set, foreign_key: true, type: :uuid, null: true
        t.timestamps
      end
      create_table :aker_set_transaction_materials do |t|
        t.uuid :aker_set_material_id
        t.references :aker_set_transaction, foreign_key: true, index: {name: 'index_operations_on_transaction_id'}
        t.timestamps
      end

    end
  end
end
