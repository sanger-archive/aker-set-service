Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      jsonapi_resources :sets do
        jsonapi_relationships
      end
    end
  end
end
