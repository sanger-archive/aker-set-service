require 'rails_helper'

RSpec.describe Aker::Material, type: :model do

  it 'can not be created without being provided a uuid' do
    expect { create(:aker_material, id: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'provides a link to itself in the Materials service' do
    material = create(:aker_material)
    expect(material.self_link).to eql("http://localhost:5000/materials/#{material.id}")
  end

end
