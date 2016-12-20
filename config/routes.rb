Rails.application.routes.draw do

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      jsonapi_resources :sets do
        jsonapi_relationships
      end
    end
  end
end
