module Api
  module V1
    class MaterialResource < JSONAPI::Resource
      model_name 'Aker::Material'

      paginator :paged

      def custom_links(options)
        { self: @model.self_link }
      end
    end
  end
end
