require 'rails_helper'

RSpec.describe 'Api::V1::Sets', type: :request do

  let(:email) { "user@here.com" }

  let(:jwt) { JWT.encode({ data: { 'user': { 'email' => email}, 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

  let(:headers) do
    {
      "Content-Type" => "application/vnd.api+json",
      "Accept" => "application/vnd.api+json",
      "HTTP_X_AUTHORISATION" => jwt,
    }
  end

  describe 'Collection' do

    describe 'GET' do

      before(:each) do
        aker_set = create_list(:aker_set, 3)

        get api_v1_sets_path, headers: headers
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'conforms to the JSON API schema' do
        expect(response).to match_api_schema('jsonapi')
      end

    end

    describe 'POST' do

      before(:each) do
        body = {
          data: {
            type: "sets",
            attributes: {
              name: "My created set"
            }
          }
        }.to_json

        post api_v1_sets_path, params: body, headers: headers
      end

      it 'should return a 201' do
        expect(response).to have_http_status(:created)
      end

      it 'should conform to the JSON API schema' do
        expect(response).to match_api_schema(:jsonapi)
      end

      it 'conforms to the Set schema' do
        expect(response).to match_api_schema('sets')
      end

      it 'has an owner' do
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:attributes][:owner][:email]).to eq email
      end

    end

    describe 'POST with owner specified' do

      let(:internal_user) { FactoryGirl.create(:user, email: 'internal@here.com') }

      before(:each) do
        body = {
          data: {
            type: "sets",
            attributes: {
              name: "My created set",
              owner: internal_user.email,
            }
          }
        }.to_json

        post api_v1_sets_path, params: body, headers: headers
      end

      it 'should return a 201' do
        expect(response).to have_http_status(:created)
      end

      it 'should conform to the JSON API schema' do
        expect(response).to match_api_schema(:jsonapi)
      end

      it 'conforms to the Set schema' do
        expect(response).to match_api_schema('sets')
      end

      it 'sets the owner to the owner specified in the payload' do
        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:data][:attributes][:owner][:email]).to eq internal_user.email
      end

      it 'sets permissions for the set for the owner and current_user' do
        aker_set = Aker::Set.last
        permission = aker_set.permissions.find_by(permittable_id: internal_user.id)
        expect(permission.has_permission?(:r))
        expect(permission.has_permission?(:w))

        current_user = User.find_by(email: "user@here.com")
        permission = aker_set.permissions.find_by(permittable_id: current_user.id)
        expect(permission.has_permission?(:r))
        expect(permission.has_permission?(:w))
      end

    end

  end

  describe 'Resource' do

    describe 'GET' do

      before(:each) do
        aker_set = create(:set_with_materials)

        get api_v1_set_path(aker_set), headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        }
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'conforms to the JSON API schema' do
        expect(response).to match_api_schema('jsonapi')
      end

      it 'conforms to the Set schema' do
        expect(response).to match_api_schema('sets')
      end

      it 'returns the Set size in the meta' do
        meta = JSON.parse(response.body)["data"]["meta"]
        expect(meta["size"]).to eql(5)
      end

    end

    describe 'PATCH' do

      before(:each) do
        aker_set = create(:aker_set)

        body = {
          data: {
            id: aker_set.id,
            type: "sets",
            attributes: {
              name: "Changed name"
            }
          }
        }.to_json

        patch api_v1_set_path(aker_set), params: body, headers: headers
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'conforms to the JSON API schema' do
        expect(response).to match_api_schema('jsonapi')
      end

      it 'conforms to the Set schema' do
        expect(response).to match_api_schema('sets')
      end

      it 'modifies the resource' do
        expect(JSON.parse(response.body)['data']['attributes']['name']).to eq('Changed name')
      end

    end

    describe 'DELETE' do

      before(:each) do
        aker_set = create(:aker_set)

        delete api_v1_set_path(aker_set), headers: headers
      end

      it 'returns a 204' do
        expect(response).to have_http_status(:no_content)
      end

      it 'has an empty response' do
        expect(response.body).to be_empty
      end

    end

  end

  describe 'Materials' do

    describe 'GET' do

      before(:each) do
        set_with_materials = create(:set_with_materials)

        get api_v1_set_materials_path(set_with_materials), headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json"
        }
      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'conforms to the JSON API schema' do
        expect(response).to match_api_schema('jsonapi')
      end

      it 'links to the Materials service' do
        body = JSON.parse(response.body)
        expect(body['data'][0]['links']['self']).to include(Rails.configuration.materials_service_url)
      end

    end

    describe 'PATCH' do

      let(:make_patch_request) do
        @set_with_materials = create(:set_with_materials)
        materials = create_list(:aker_material, 3)

        body = {
          data: materials.map { |material| { id: material.id, type: "materials" } }
        }.to_json

        patch api_v1_set_relationships_materials_path(@set_with_materials), params: body, headers: headers
      end

      context 'when uuids exist in Materials service' do
        before(:each) do
          allow(Material).to receive(:valid?).and_return(true)
          make_patch_request
        end

        it 'returns a 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'replaces all materials' do
          expect(@set_with_materials.materials.count).to eql(3)
        end
      end

      context 'when uuids do not exist in Materials service' do
        before(:each) do
          allow(Material).to receive(:valid?).and_return(false)
          make_patch_request
        end

        it 'returns a 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

    end

    describe 'POST' do

      let(:make_post_request) do
        @set_with_materials = create(:set_with_materials)
        materials = create_list(:aker_material, 3)

        body = {
          data: materials.map { |material| { id: material.id, type: "materials" } }
        }.to_json

        post api_v1_set_relationships_materials_path(@set_with_materials), params: body, headers: headers
      end

      context 'when uuids exist in Materials service' do
        before(:each) do
          allow(Material).to receive(:valid?).and_return(true)
          make_post_request
        end

        it 'returns a 204' do
          expect(response).to have_http_status(:no_content)
        end

        it 'adds the new materials to the set' do
          expect(@set_with_materials.materials.count).to eql(8)
        end
      end

      context 'when uuids do not exist in Materials service' do
        before(:each) do
          allow(Material).to receive(:valid?).and_return(false)
          make_post_request
        end

        it 'returns a 422' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

    end

    describe 'DELETE' do

      before(:each) do
        @set_with_materials = create(:set_with_materials)

        body = {
          data: [{ id: @set_with_materials.materials.first.id, type: "materials" }]
        }.to_json

        delete api_v1_set_relationships_materials_path(@set_with_materials), params: body, headers: headers
      end

      it 'returns a 204' do
        expect(response).to have_http_status(:no_content)
      end

      it 'removes the material from the set' do
        expect(@set_with_materials.materials.count).to eql(4)
      end

    end

  end

  describe 'JWT' do

    describe 'GET with correct secret_key' do

      before(:each) do
        aker_set = create(:set_with_materials)
        payload = { data: {} }
        token = JWT.encode payload, Rails.configuration.jwt_secret_key, 'HS256'

        get api_v1_set_path(aker_set), headers: headers

      end

      it 'returns a 200' do
        expect(response).to have_http_status(:ok)
      end

    end

    describe 'GET with bad_key' do

      before(:each) do
        aker_set = create(:set_with_materials)
        payload = { data: {} }
        token = JWT.encode payload, 'x', 'HS256'

        get api_v1_set_path(aker_set), headers: {
          "Content-Type": "application/vnd.api+json",
          "Accept": "application/vnd.api+json",
          "HTTP_X_AUTHORISATION": token
        }

      end

      it 'returns a 401' do
        expect(response).to have_http_status(:unauthorized)
      end

    end

  end

  describe 'filtering' do
    context 'When filtering owner email' do
      let!(:jeff) { create(:user, email: "jeff@here.com" ) }
      let!(:dirk) { create(:user, email: "dirk@here.com" ) }

      let!(:sets) do
        [
          create(:aker_set, owner: jeff),
          create(:aker_set, owner: dirk),
          create(:aker_set, owner: jeff),
        ]
      end

      context 'When a known owner is specified' do

        it 'returns the sets with the given owner' do
          get api_v1_sets_path, params: { "filter[owner]" => jeff.email }, headers: {
            "Content-Type": "application/vnd.api+json",
            "Accept": "application/vnd.api+json",
          }
          @body = JSON.parse(response.body, symbolize_names: true)
          expect(@body[:data].length).to eq 2
        end

      end

      context 'When an unknown owner is specified' do

        it 'returns no sets' do
          get api_v1_sets_path, params: { "filter[owner]" => 'bananas' }, headers: {
            "Content-Type": "application/vnd.api+json",
            "Accept": "application/vnd.api+json",
          }
          @body = JSON.parse(response.body, symbolize_names: true)
          expect(@body[:data].length).to eq 0
        end
      end
    end
  end

end