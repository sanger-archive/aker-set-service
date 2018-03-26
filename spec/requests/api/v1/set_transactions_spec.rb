require 'rails_helper'

RSpec.describe 'Api::V1::SetTransactions', type: :request do

  let(:email) { "user@here.com" }

  let(:jwt) { JWT.encode({ data: { 'email' => email, 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

  let(:headers) do
    {
      "Content-Type" => "application/vnd.api+json",
      "Accept" => "application/vnd.api+json",
      "HTTP_X_AUTHORISATION" => jwt,
    }
  end

  describe 'Transactions' do
    let(:aker_set) { create(:aker_set) }
    before do
      allow(Material).to receive(:valid?).and_return(true)
    end
    let(:body){ {
        data: { type: 'set_transactions', attributes: { aker_set_id: aker_set.id, 
          operation: 'add', status: 'building' } }
    }.to_json }

    # First msg
    let(:first_materials_list) { create_list(:aker_material, 3) }
    let(:first_materials_message) {
      { data: first_materials_list.map{|m| {id: m.id, type: 'materials'}} }.to_json
    }

    # Second msg
    let(:second_materials_list) { create_list(:aker_material, 3) }
    let(:second_materials_message) {
      { data: second_materials_list.map{|m| {id: m.id, type: 'materials'}} }.to_json
    }

    let(:added_material_ids) { [first_materials_list, second_materials_list].flatten.map(&:id) }

    describe 'Create (POST)' do
      

      it 'returns a 201' do
        post api_v1_set_transactions_path, params: body, headers: headers
        expect(response).to have_http_status(:created)
      end

      it 'conforms to the JSON API schema' do
        post api_v1_set_transactions_path, params: body, headers: headers
        expect(response).to match_api_schema('jsonapi')
      end

      it 'creates a new transaction' do
        expect{
          post api_v1_set_transactions_path, params: body, headers: headers
        }.to(change{
          Aker::SetTransaction.where(aker_set_id: aker_set.id).count
        }.from(0).to(1))
      end

      it 'cannot create a new transaction from a locked set' do
        aker_set.update_attributes(locked: true)
        post api_v1_set_transactions_path, params: body, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Aker::SetTransaction.where(aker_set_id: aker_set.id).count).to eq(0)
      end

      it 'cannot create a new transaction if you do not have write permissions on the set' do
        aker_set.update_attributes(owner_id: 'someone@else')
        post api_v1_set_transactions_path, params: body, headers: headers
        expect(response).to have_http_status(:forbidden)
        expect(Aker::SetTransaction.where(aker_set_id: aker_set.id).count).to eq(0)
      end

      context 'when the transaction operation is create' do

        it 'creates a new transaction when a set name is provided' do
          body = {
            data: { type: 'set_transactions', attributes: { set_name: 'testforset', 
              operation: 'create', status: 'building' } }
          }.to_json 
          post api_v1_set_transactions_path, params: body, headers: headers
          expect(response).to have_http_status(:created)
        end
        it 'does not create a transaction without a set name' do
          body = {
            data: { type: 'set_transactions', attributes: { 
              operation: 'create', status: 'building' } }
          }.to_json 
          post api_v1_set_transactions_path, params: body, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a transaction if both set name and set id are defined' do
          body = {
            data: { type: 'set_transactions', attributes: { 
              set_name: 'testforset',  aker_set_id: aker_set.id, 
              operation: 'create', status: 'building' } }
          }.to_json 
          post api_v1_set_transactions_path, params: body, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)

        end

        it 'does not create a transaction if set id is defined' do
          body = {
            data: { type: 'set_transactions', attributes: { 
              aker_set_id: aker_set.id, 
              operation: 'create', status: 'building' } }
          }.to_json 
          post api_v1_set_transactions_path, params: body, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)

        end


      end

    end

    describe 'Update (PUT)' do

      before do
        post api_v1_set_transactions_path, params: body, headers: headers
        @transaction_id = JSON.parse(response.body)['data']['id']
      end

      it 'adds all materials in subsequent requests to the transaction batch' do
        post api_v1_set_transaction_relationships_materials_path(@transaction_id), 
          params: first_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)
        post api_v1_set_transaction_relationships_materials_path(@transaction_id), 
          params: second_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)

        transaction = Aker::SetTransaction.where(aker_set_id: aker_set.id).first
        created_material_ids_from_transaction = transaction.materials.map(&:aker_set_material_id)

        expect(created_material_ids_from_transaction).to eq(added_material_ids)
      end

      it 'cannot add new materials to a transaction with a locked set' do
        aker_set.update_attributes(locked: true)
        post api_v1_set_transaction_relationships_materials_path(@transaction_id), 
          params: first_materials_message, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        transaction = Aker::SetTransaction.where(aker_set_id: aker_set.id).first
        created_material_ids_from_transaction = transaction.materials.map(&:aker_set_material_id)

        expect(created_material_ids_from_transaction).to eq([])
      end      

      context 'Commit (status to done)' do
        let(:commit_message) { 
          {
            data: { 
              id: @transaction_id,
              type: 'set_transactions', attributes: { 
              aker_set_id: aker_set.id, status: 'done', 
            } }
          }.to_json 
        }

        let(:not_commit_message) { 
          {
            data: { 
              id: @transaction_id,
              type: 'set_transactions', attributes: { 
              aker_set_id: aker_set.id, status: 'building', 
            } }
          }.to_json 
        }


        it 'commits all changes to the destination set when changing status do "done"' do
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
          expect(response).to have_http_status(:no_content)
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
          expect(response).to have_http_status(:no_content)
          put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
          expect(response).to have_http_status(:ok)

          expect(Aker::Set.find(aker_set.id).materials.map(&:id)).to eq(added_material_ids)
        end

        it 'does not allow you to change anything after the status is set to "done"' do
          put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
          expect(response).to have_http_status(:ok)
          put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not commit the changes if there is no change of status' do
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
          expect(response).to have_http_status(:no_content)
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
          expect(response).to have_http_status(:no_content)
          put api_v1_set_transaction_path(@transaction_id), params: not_commit_message, headers: headers
          expect(response).to have_http_status(:ok)
          expect(Aker::Set.find(aker_set.id).materials.count).to eq(0)
        end

        it 'can not add new materials after completing a transaction' do
          put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
          expect(response).to have_http_status(:ok)
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          expect(Aker::Set.find(aker_set.id).materials.count).to eq(0)
        end

        it 'can not commit changes to a destination set when it is locked' do
          aker_set.update_attributes(locked: true)
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
          post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
          expect(response).to have_http_status(:unprocessable_entity)

          put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers        
          expect(response).to have_http_status(:unprocessable_entity)
          expect(Aker::Set.find(aker_set.id).materials.map(&:id)).to eq([])          
        end

        context 'when the operation is "create"' do
          let(:body_with_set_name){ {
              data: { type: 'set_transactions', attributes: { 
                operation: 'create', status: 'building', set_name: 'anothertest1' } }
          }.to_json }

          let(:commit_message_without_set_name) { 
            {
              data: { 
                id: @transaction_id,
                type: 'set_transactions', attributes: { 
                status: 'done', set_name: nil
              } }
            }.to_json 
          }
          let(:commit_message_without_set_name_with_set_id) { 
            {
              data: { 
                id: @transaction_id,
                type: 'set_transactions', attributes: { 
                aker_set_id: aker_set.id, status: 'done', set_name: nil
              } }
            }.to_json 
          }
          let(:commit_message) { 
            {
              data: { 
                id: @transaction_id,
                type: 'set_transactions', attributes: { 
                status: 'done', 
              } }
            }.to_json 
          }



          it 'does not allow you to commit when you try to set a null set name in the commit message' do
            post api_v1_set_transactions_path, params: body_with_set_name, headers: headers
            @transaction_id = JSON.parse(response.body)['data']['id']

            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
            expect(response).to have_http_status(:no_content)
            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
            expect(response).to have_http_status(:no_content)
            put api_v1_set_transaction_path(@transaction_id), params: commit_message_without_set_name, headers: headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not allow you to commit when you try to set a set id in the commit message' do
            post api_v1_set_transactions_path, params: body_with_set_name, headers: headers
            @transaction_id = JSON.parse(response.body)['data']['id']

            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
            expect(response).to have_http_status(:no_content)
            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
            expect(response).to have_http_status(:no_content)
            put api_v1_set_transaction_path(@transaction_id), params: commit_message_without_set_name_with_set_id, headers: headers
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'creates the new set and commits all changes to the destination set when changing status do "done"' do
            post api_v1_set_transactions_path, params: body_with_set_name, headers: headers
            @transaction_id = JSON.parse(response.body)['data']['id']

            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
            expect(response).to have_http_status(:no_content)
            post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: second_materials_message, headers: headers        
            expect(response).to have_http_status(:no_content)
            put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
            expect(response).to have_http_status(:ok)

            expect(Aker::Set.find_by(name: 'anothertest1').owner_id).to eq(email)
            expect(Aker::Set.find_by(name: 'anothertest1').materials.map(&:id)).to eq(added_material_ids)
          end

        end

      end

    end

    describe 'Destroy (DELETE)' do
      let(:commit_message) { 
        {
          data: { 
            id: @transaction_id,
            type: 'set_transactions', attributes: { 
            aker_set_id: aker_set.id, operation: 'add', status: 'done', 
          } }
        }.to_json 
      }

      before do
        post api_v1_set_transactions_path, params: body, headers: headers
        @transaction_id = JSON.parse(response.body)['data']['id']
      end

      it 'removes the transaction' do
        expect{
          delete api_v1_set_transaction_path(@transaction_id), headers: headers
        }.to(change{Aker::SetTransaction.where(id: @transaction_id).count}.from(1).to(0))
      end
      it 'does not remove the commited changes to the set' do
        post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)
        put api_v1_set_transaction_path(@transaction_id), params: commit_message, headers: headers
        expect(response).to have_http_status(:ok)
        expect(Aker::Set.find(aker_set.id).materials.count).not_to eq(0)

        expect {
          delete api_v1_set_transaction_path(@transaction_id), headers: headers
          }.not_to(change{
            Aker::Set.find(aker_set.id).materials.count
        })
      end
      it 'does not commit changes to the set on deletion' do
        post api_v1_set_transaction_relationships_materials_path(@transaction_id), params: first_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)
        expect(Aker::Set.find(aker_set.id).materials.count).to eq(0)

        expect {
          delete api_v1_set_transaction_path(@transaction_id), headers: headers
          }.not_to(change{
            Aker::Set.find(aker_set.id).materials.count
        })
      end

    end

    context 'when building several transactions in parallel' do
      before do
        post api_v1_set_transactions_path, params: body, headers: headers
        @transaction_id1 = JSON.parse(response.body)['data']['id']
        @transaction1 = Aker::SetTransaction.find(@transaction_id1)

        post api_v1_set_transactions_path, params: body, headers: headers
        @transaction_id2 = JSON.parse(response.body)['data']['id']
        @transaction2 = Aker::SetTransaction.find(@transaction_id2)
      end

      it 'keeps content for each transaction independently from the others' do
        post api_v1_set_transaction_relationships_materials_path(@transaction_id1), 
          params: first_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)

        post api_v1_set_transaction_relationships_materials_path(@transaction_id2), 
          params: second_materials_message, headers: headers
        expect(response).to have_http_status(:no_content)

        created_material_ids_from_transaction1 = @transaction1.materials.map(&:aker_set_material_id)
        created_material_ids_from_transaction2 = @transaction2.materials.map(&:aker_set_material_id)

        expect(created_material_ids_from_transaction1).to eq(first_materials_list.map(&:id))
        expect(created_material_ids_from_transaction2).to eq(second_materials_list.map(&:id))
      end

      context 'when committing changes' do
        let(:commit_message1) { 
          {
            data: { 
              id: @transaction_id1,
              type: 'set_transactions', attributes: { 
              aker_set_id: aker_set.id, operation: 'add', status: 'done', 
            } }
          }.to_json 
        }

        let(:commit_message2) { 
          {
            data: { 
              id: @transaction_id2,
              type: 'set_transactions', attributes: { 
              aker_set_id: aker_set.id, operation: 'add', status: 'done', 
            } }
          }.to_json 
        }


        it 'commits changes for each transaction independently from the others' do
          post api_v1_set_transaction_relationships_materials_path(@transaction_id1), 
            params: first_materials_message, headers: headers
          expect(response).to have_http_status(:no_content)

          post api_v1_set_transaction_relationships_materials_path(@transaction_id2), 
            params: second_materials_message, headers: headers
          expect(response).to have_http_status(:no_content)

          expect(aker_set.materials.count).to eq(0)
          put api_v1_set_transaction_path(@transaction_id1), params: commit_message1, headers: headers
          expect(response).to have_http_status(:ok)
          expect(aker_set.materials.map(&:id)).to eq(first_materials_list.map(&:id))
          put api_v1_set_transaction_path(@transaction_id2), params: commit_message2, headers: headers
          expect(response).to have_http_status(:ok)
          aker_set.materials.reload
          expect(aker_set.materials.map(&:id)).to eq(added_material_ids)
        end
      end
    end

  end

end