class ChangeSetOwnerToBeCaseInsensitive < ActiveRecord::Migration[5.0]
  def up
    enable_extension 'citext'
    change_column :aker_sets, :owner_id, :citext
    Aker::Set.where.not(owner_id: nil).find_each do |s|
      if s.sanitise_owner
        s.save!(validate: false) # This will work even for locked sets
      end
    end
  end

  def down
    change_column :aker_sets, :owner_id, :string
  end  
end
