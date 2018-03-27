module Api
  module V1
    class SetTransactionResource < JSONAPI::Resource
      key_type :integer
      model_name 'Aker::SetTransaction'
      attributes :operation, :status, :aker_set_id, :batch_size, :set_name, :owner_id

      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      has_one :set, foreign_key: :aker_set_id


      def meta(options)
        {
          size: @model.materials.count
        }
      end

      # this is needed in case we use a 'create' operation. The user that creates the transaction
      # will be assigned as the creator of the set when providing the commit request
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

      after_save do
        if @model.done?
          @model.apply_materials_in_transaction!
        end
      end

    end
  end
end
