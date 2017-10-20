require 'swagger_helper'

describe 'Sets API' do

  let(:jwt) { JWT.encode({ data: { 'email' => 'user@here.com', 'groups' => ['world'] } }, Rails.configuration.jwt_secret_key, 'HS256') }

  path '/api/v1/sets' do

    get 'Fetches Sets' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
      
      response '200', 'sets found' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :uuid },
                type: { type: :string, default: "sets" },
                attributes: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    created_at: { type: :dateTime}
                  }
                }
              }
            }
          }
        }

        run_test!
      end
    end

    post 'Creates a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :set, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, default: "sets" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string, uniqueItems: true }
                }
              }
            }
          }
        }
      }
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      response '201', 'set created' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        let(:set) do
          set = build(:aker_set)

          {
            data: {
              type: "sets",
              attributes: {
                name: set.name
              }
            }
          }
        end

        run_test!
      end
    end

  end

  path '/api/v1/sets/{uuid}' do

    get 'Retrieves a set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :uuid, in: :path, type: :uuid
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      response '200', 'set found' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :uuid },
              type: { type: :string, default: "sets" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string }
                }
              }
            }
          }
        }

        let(:uuid) do
          create(:aker_set).id
        end

        run_test!
      end
    end

    patch 'Updates a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
      parameter name: :uuid, in: :path, type: :uuid

      parameter name: :set, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string, default: "sets" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string }
                }
              }
            }
          }
        }
      }

      response '200', 'set updated' do
        let(:HTTP_X_AUTHORISATION) { jwt }

        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string, default: "sets" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string }
                }
              }
            }
          }
        }

        let(:uuid) do
          create(:aker_set).id
        end

        let(:set) do
          set = build(:aker_set)

          {
            data: {
              id: uuid,
              type: "sets",
              attributes: {
                name: set.name
              }
            }
          }
        end

        run_test!

      end
    end

    delete 'Deletes a set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string
      parameter name: :uuid, in: :path, type: :uuid

      response '204', 'set deleted' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        let(:uuid) do
          create(:aker_set).id
        end
        run_test!
      end
    end
  end

  path '/api/v1/sets/{uuid}/materials' do

    get 'Fetches Materials of a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'
      parameter name: :uuid, in: :path, type: :uuid
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      response '200', 'materials found' do
        let(:HTTP_X_AUTHORISATION) { jwt }
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string, default: "materials" }
              }
            }
          }
        }

        let(:uuid) do
          create(:set_with_materials).id
        end

        run_test!
      end

    end

  end

  path '/api/v1/sets/{uuid}/relationships/materials' do

    before(:each) do
      allow(Material).to receive(:valid?).and_return(true)
    end

    patch 'Replaces Materials in a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      parameter name: :uuid, in: :path, type: :uuid

      parameter name: :materials, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string, default: "materials" }
              }
            }
          }
        }
      }

      response '204', 'materials replaced' do
        let(:HTTP_X_AUTHORISATION) { jwt }

        let(:uuid) do
          create(:aker_set).id
        end

        let(:materials) do
          {
            data: create_list(:aker_material, 3).map { |material| { id: material.id, type: "materials" } }
          }
        end

        run_test!

      end

    end

    post 'Adds Materials to a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :uuid, in: :path, type: :uuid
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      parameter name: :materials, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string, default: "materials" }
              }
            }
          }
        }
      }

      response '204', 'materials added' do
        let(:HTTP_X_AUTHORISATION) { jwt }

        let(:uuid) do
          create(:aker_set).id
        end
        let(:materials) do
          {
            data: create_list(:aker_material, 3).map { |material| { id: material.id, type: "materials" } }
          }
        end

        run_test!

      end

    end

    delete 'Deletes Materials from a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :uuid, in: :path, type: :uuid
      parameter name: 'HTTP_X_AUTHORISATION', in: :header, type: :string

      parameter name: :materials, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :string },
                type: { type: :string, default: "materials" }
              }
            }
          }
        }
      }

      response '204', 'materials deleted' do
        let(:HTTP_X_AUTHORISATION) { jwt }

        let(:set_with_materials) do
          create(:set_with_materials)
        end

        let(:uuid) { set_with_materials.id }

        let(:materials) do
          {
            data: [{ id: set_with_materials.materials.first.id, type: "materials" }]
          }
        end

        run_test!

      end

    end

  end

end