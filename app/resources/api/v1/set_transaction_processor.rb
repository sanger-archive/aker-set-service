module Api
  module V1
    class SetTransactionProcessor < JSONAPI::Processor

      def create_to_many_relationships
        new_set_materials = Set.new(data) - model.material_ids
        bulk_insert!(model, new_set_materials)
        return JSONAPI::OperationResult.new(:no_content, result_options)
      end

    private

      def resource_id
        params[:resource_id]
      end

      # The array of material uuids from the request
      def data
        params.fetch(:data)
      end

      # The resource we want to operate on
      def resource
        resource_klass.find_by_key(resource_id, context: context)
      end

      # The instance of Aker::Set we want to operate on
      def model
        resource._model
      end

      # bulk_insert class method comes from the "BulkInsert" gem
      # https://github.com/jamis/bulk_insert#usage
      def bulk_insert!(aker_set, material_ids)
        set_material_attrs = material_ids.map do |material_id|
          { aker_set_transaction_id: aker_set.id, aker_set_material_id: material_id }
        end

        Aker::SetTransactionMaterial.bulk_insert(values: set_material_attrs)
      end



    end
  end
end