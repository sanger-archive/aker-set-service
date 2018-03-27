class AddSetNameToSetTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :aker_set_transactions, :set_name, :string, defaults: :null
  end
end
