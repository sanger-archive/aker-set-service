module Api
  module V1
    class SetTransactionResource < JSONAPI::Resource
      key_type :integer
      model_name 'Aker::SetTransaction'
      attributes :operation, :status, :aker_set_id, :batch_size

      has_many :materials, class_name: 'Material', relation_name: :materials, acts_as_set: true

      has_one :set, foreign_key: :aker_set_id


      def meta(options)
        {
          size: @model.materials.count
        }
      end

      after_save do
        if @model.done?
          @model.apply_materials_in_transaction!
        end
      end

    end
  end
end
