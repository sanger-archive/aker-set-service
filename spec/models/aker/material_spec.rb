require 'rails_helper'

RSpec.describe Aker::Material, type: :model do

  it 'can not be created without being provided a uuid' do
    expect { create(:aker_material, id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

end
