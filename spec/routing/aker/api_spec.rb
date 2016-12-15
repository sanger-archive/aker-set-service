require 'rails_helper'

RSpec.describe 'API routing', type: :routing do

  describe 'Set' do

    describe 'collection' do

      it 'routes to the index' do
        expect(get: '/api/v1/sets').to be_routable
      end

      it 'routes to create' do
        expect(post: '/api/v1/sets').to be_routable
      end

    end


    describe 'resource' do

      before(:each) do
        @set = create(:aker_set)
      end

      it 'routes to show' do
        expect(get: '/api/v1/sets/' + @set.id).to be_routable
      end

      it 'routes to update' do
        expect(patch: '/api/v1/sets/' + @set.id).to be_routable
      end

      it 'routes to delete' do
        expect(delete: '/api/v1/sets/' + @set.id).to be_routable
      end

    end

  end

end