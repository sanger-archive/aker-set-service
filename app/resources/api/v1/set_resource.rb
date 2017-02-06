module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      attributes :name, :created_at
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      def meta(options)
        {
          size: @model.materials.count
        }
      end
    end
  end
end
