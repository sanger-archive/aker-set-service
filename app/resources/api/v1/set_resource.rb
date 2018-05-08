module Api
  module V1
    class SetResource < JSONAPI::Resource
      model_name 'Aker::Set'
      paginator :paged
      attributes :name, :owner_id, :created_at, :locked
      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true
      has_many :set_transactions, class_name: 'SetTransaction', relation_name: :set_transaction

      filter :name
      filter :locked
      # http://localhost:3000/api/v1/sets?filter[owner_id]=guest
      filter :owner_id, apply: -> (records, value, _options) {
        return records.none if value.nil?
        records.where(owner_id: value)
      }

      filter :search_by_name, apply: -> (records, value, _options) {
        return records.none if value.nil? || value.empty?
        records.where('name LIKE ?', "#{value[0]}%")
      }

      # sets?filter[empty]=true
      # If the value is true only return empty sets
      # If it's false only return inhabited sets
      # Anything else and don't filter
      filter :empty, apply: -> (records, value, _options) {
        # value is actually an Array as JSON API supports multiple filter values (separated by comma)
        # We're gonna just take the first if that's the case
        value.first == 'true' ? records.empty : ((value.first == 'false') ? records.inhabited : records)
      }

      before_create do
        user = context[:current_user]
        owner_email = context[:owner_id]

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

      def meta(options)
        {
          size: @model.materials.count
        }
      end
    end
  end
end
