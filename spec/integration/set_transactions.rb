require 'swagger_helper'

describe 'Set Transactions API' do

  let(:jwt) { JWT.encode({ data: { 'email' => 'user@here.com', 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

  before do
    @set_transaction_schema = {
      type: :object,
      properties: {
        data: {
          type: :object,
          properties: {
            aker_set_id: { type: :uuid},
            operation: { type: :string},
            status: { type: :string} ,
            batch_size: { type: :integer},
            materials: {type: :array, items: {type: :uuid}}
          }
        }
      }
    }
  end


  path '/api/v1/set-transactions' do
    before(:each) do
      allow(Material).to receive(:valid?).and_return(true)
    end

    post 'Creates a new transaction' do
      tags 'Transactions'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
      parameter name: :"set-transaction", in: :body, schema: @set_transaction_schema


      response '204', 'transaction created' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        let(:my_set) { create(:aker_set) }
        let(:uuid) do
          my_set.id
        end
        let(:transaction) { my_set.set_transactions.create! }
        let(:transactionId) { transaction.id }
        let(:"set-transaction") { 
          { 
            data: { type: 'set_transactions', attributes: { 
              aker_set_id: my_set.id, 
              operation: 'add', status: 'building' } }
          }
        }

        run_test!
      end
    end

    path '/api/v1/set-transactions/{id}' do
      get 'Get the transaction information' do
        tags 'Transactions'
        consumes 'application/vnd.api+json'
        produces 'application/vnd.api+json'
        parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
        parameter name: :id, in: :path, type: :integer

        response '201', 'transaction shown' do
          let(:HTTP_X_AUTHORISATION) { jwt }
          let(:my_set) { create(:aker_set) }
          let(:uuid) do
            my_set.id
          end
          let(:transaction) { my_set.set_transactions.create! }
          let(:id) { transaction.id }

          run_test!
        end
      end

    end
    path '/api/v1/set-transactions/{id}/relationships/materials' do
      post 'Add or removes materials to a set in a transaction' do
        tags 'Transactions'
        consumes 'application/vnd.api+json'
        produces 'application/vnd.api+json'
        parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
        parameter name: :id, in: :path, type: :integer
        parameter name: :"set-transaction", in: :body, schema: @set_transaction_schema

        response '204', 'transaction modified' do
          let(:HTTP_X_AUTHORISATION) { jwt }
          let(:my_set) { create(:aker_set) }
          let(:uuid) do
            my_set.id
          end
          let(:transaction) { my_set.set_transactions.create! }
          let(:id) { transaction.id }

          let(:materials) do
            {
              data: create_list(:aker_material, 3).map {|material| { id: material.id, type: "materials"}}
            }
          end

          let(:"set-transaction") { 
            { data: 
              { type: "set-transactions", 
                attributes: {
                  aker_set_id: uuid,
                  type: 'add',
                  status: 'building',
                  materials: materials[:data].pluck(:id)
                }
              }
            }
          }

          run_test!
        end
      end
      put 'Commit a transaction' do
        tags 'Transactions'
        consumes 'application/vnd.api+json'
        produces 'application/vnd.api+json'
        parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
        parameter name: :id, in: :path, type: :integer
        parameter name: :"set-transaction", in: :body, schema: @set_transaction_schema

        response '204', 'transaction commited' do
          let(:HTTP_X_AUTHORISATION) { jwt }
          let(:my_set) { create(:aker_set) }
          let(:uuid) do
            my_set.id
          end
          let(:transaction) { my_set.set_transactions.create! }
          let(:id) { transaction.id }

          let(:"set-transaction") { 
            { data: 
              { type: "set-transactions", 
                attributes: {
                  status: 'done'
                }
              }
            }
          }

          run_test!
        end
      end
    end

  end

end