class Aker::SetTransactionMaterial < ActiveRecord::Base
  belongs_to :aker_set_transaction, class_name: "Aker::SetTransaction", foreign_key: :aker_set_transaction_id
end