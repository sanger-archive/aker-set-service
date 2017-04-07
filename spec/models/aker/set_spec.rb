require 'rails_helper'

RSpec.describe Aker::Set, type: :model do

  it 'is not valid without a name' do
    expect(build(:aker_set, name: nil)).to_not be_valid
  end

  it 'is not valid without a unique name' do
    set = create(:aker_set)
    expect(build(:aker_set, name: set.name)).to_not be_valid
  end

  it 'can be edited when unlocked' do
    set = create(:aker_set, name: 'jeff')
    expect(set.name).to eq 'jeff'
    expect(set.update_attributes(name: 'dave')).to eq true
    expect(set).to be_valid
    expect(set.name).to eq 'dave'
  end

  it 'cannot be unlocked' do
    set = create(:aker_set, locked: true)
    expect(set).to be_valid
    expect(set.update_attributes(name: 'dirk')).to eq false
    expect(set).to_not be_valid
  end

  it 'cannot be edited after locking' do
    set = create(:aker_set, name: 'jeff')
    expect(set.update_attributes(locked: true)).to eq true
    expect(set).to be_valid
    expect(set.update_attributes(name: 'dirk')).to eq false
    expect(set).to_not be_valid
  end

  it 'can have an owner' do
    set = create(:aker_set, name: 'jeff')
    user = create(:user)
    set.owner_id = user.email
    set.save
    set = Aker::Set.find(set.id)
    expect(set.owner_id).to eq user.email
  end

  it 'has permissions' do
    set = create(:aker_set, name: 'jeff')
    # Factory girl will set initial permissions on the set
    user = create(:user, email: 'dirk@here.com')
    #world = create(:group, name: 'world')
    ability = Ability.new({ 'user' => user, 'groups' => ["world"]})
    expect(ability.can?(:read, set)).to eq true
    expect(ability.can?(:write, set)).to eq false

    set.permissions.create(permitted: user.email, permissions: [:r, :w])
    expect(ability.can?(:read, set)).to eq true
    expect(ability.can?(:write, set)).to eq true
  end
end
