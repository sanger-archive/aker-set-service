module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      attributes :name, :created_at, :locked
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      after_create do
        @model.set_permission(context[:current_user]['user'])
      end

      def meta(options)
        {
          size: @model.materials.count
        }
      end

    end
  end
end
