module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      attributes :name, :created_at, :locked
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      after_create do
        user = context[:current_user]['user']
        @model.set_permission(user)
        @model.owner = user
        @model.save!
      end

      def meta(options)
        {
          size: @model.materials.count
        }
      end

    end
  end
end
