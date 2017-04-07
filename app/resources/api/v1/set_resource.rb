module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      attributes :name, :owner, :created_at, :locked
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      # http://localhost:3000/api/v1/sets?filter[owner]="guest"
      filter :owner, apply: -> (records, value, _options) {
        user = User.find_by(email: value)
        return records.none if user.nil?
        records.where(owner: user)
      }

      before_create do
        user = context[:current_user]['user']
        owner_email = context[:owner]

        if owner_email.nil?
          @model.owner = user.email
        else
          @model.owner = owner_email
        end
      end

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
