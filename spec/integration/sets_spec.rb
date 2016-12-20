require 'swagger_helper'

describe 'Sets API' do

  path '/api/v1/sets' do

    get 'Fetches Sets' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      response '200', 'sets found' do
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
                    name: { type: :string }
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
                  name: { type: :string }
                }
              }
            }
          }
        }
      }

      response '201', 'set created' do
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

      response '200', 'set found' do
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

        let(:uuid) { create(:aker_set).id }

        run_test!
      end
    end

    patch 'Updates a Set' do
      tags 'Sets'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

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

        let(:uuid) { create(:aker_set).id }

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

      parameter name: :uuid, in: :path, type: :uuid

      response '204', 'set deleted' do
        let(:uuid) { create(:aker_set).id }
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

      response '200', 'materials found' do
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

        let(:uuid) { create(:set_with_materials).id }

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

        let(:uuid) { create(:aker_set).id }

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

        let(:uuid) { create(:aker_set).id }

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
        let(:set_with_materials) { create(:set_with_materials) }

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