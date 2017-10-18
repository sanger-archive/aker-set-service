class ChangeSetNameToBeCaseInsensitive < ActiveRecord::Migration[5.0]
  def change
    enable_extension 'citext'
    change_column :aker_sets, :name, :citext
  end
end
