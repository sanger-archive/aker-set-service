require 'rails_helper'
require 'ability'

RSpec.describe Aker::Set, type: :model do

  it 'is not valid without a name' do
    expect(build(:aker_set, name: nil)).to_not be_valid
  end

  it 'is not valid without a unique name' do
    set = create(:aker_set)
    expect(build(:aker_set, name: set.name)).to_not be_valid
  end

  it 'is not valid with a different capitalisation of an exising name' do
    set = create(:aker_set, name: 'jeff_set')
    expect(build(:aker_set, name: 'JEFF_SET')).not_to be_valid
  end

  it 'has its name stripped' do
    set = create(:aker_set, name: '  jeff  ')
    expect(set.name).to eq('jeff')
  end

  it 'is not valid without a unique stripped name' do
    set = create(:aker_set, name: '  jeff')
    expect(build(:aker_set, name: 'JEFF  ')).not_to be_valid
  end

  context 'when the set is unlocked' do
    it 'can be edited' do
      set = create(:aker_set, name: 'jeff')
      expect(set.name).to eq 'jeff'
      expect(set.update_attributes(name: 'dave')).to eq true
      expect(set).to be_valid
      expect(set.name).to eq 'dave'
    end
  end

  context 'when the set is locked' do
    it 'cannot be unlocked' do
      set = create(:aker_set, locked: true)
      expect(set).to be_valid
      expect(set.update_attributes(locked: false)).to eq false
      expect(set).to_not be_valid
    end

    it 'cannot be edited' do
      set = create(:aker_set, name: 'jeff')
      expect(set.update_attributes(locked: true)).to eq true
      expect(set).to be_valid
      expect(set.update_attributes(name: 'dirk')).to eq false
      expect(set).to_not be_valid
    end

    it 'can not have materials added to it' do
      set = create(:aker_set, locked: true)
      materials = create_list(:aker_material, 3)
      expect { set.materials << materials }.to raise_error(ActiveRecord::RecordInvalid, /Set is locked/)
    end
  end

  it 'can have an owner' do
    set = create(:aker_set, name: 'jeff')
    set.owner_id = 'someone_else@there.com'
    set.save
    set = Aker::Set.find(set.id)
    expect(set.owner_id).to eq 'someone_else@there.com'
  end

  it 'has correct privileges' do
    set = create(:aker_set, name: 'jeff')
    ability = Ability.new(OpenStruct.new('email' => 'dirk@here.com', 'groups' => ["world"]))
    expect(ability.can?(:read, set)).to eq true
    expect(ability.can?(:write, set)).to eq false
    ability = Ability.new(OpenStruct.new('email' => set.owner_id, 'groups' => []))
    expect(ability.can?(:read, set)).to eq true
    expect(ability.can?(:write, set)).to eq true
  end

  it 'finds names case insensitively' do
    s = create(:aker_set, name: 'jeff')
    t = Aker::Set.find_by(name: 'JEFF')
    expect(t).to eq(s)
  end
end
