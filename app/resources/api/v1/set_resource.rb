module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      attributes :name, :owner_id, :created_at, :locked
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      # http://localhost:3000/api/v1/sets?filter[owner]="guest"
      filter :owner, apply: -> (records, value, _options) {
        #user = User.find_by(email: value)
        return records.none if value.nil?
        records.where(owner_id: value)
      }

      before_create do
        user = context[:current_user]['user']
        owner_email = context[:owner]

        if owner_email.nil?
          if user.is_a? Hash
            @model.owner_id = user['email']
          else
            @model.owner_id = user.email
          end
        else
          @model.owner_id = owner_email
        end
      end

      after_create do
        user = context[:current_user]['user']
        @model.set_default_permission(user['email'])
        @model.owner_id = user['email']
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
