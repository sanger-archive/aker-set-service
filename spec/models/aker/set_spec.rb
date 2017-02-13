require 'rails_helper'

RSpec.describe Aker::Set, type: :model do

  it 'is not valid without a name' do
    expect(build(:aker_set, name: nil)).to_not be_valid
  end

  it 'is not valid without a unique name' do
    set = create(:aker_set)
    expect(build(:aker_set, name: set.name)).to_not be_valid
  end

end
