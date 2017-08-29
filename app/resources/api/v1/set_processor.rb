require 'set'

module Api
  module V1

    # Check out http://jsonapi-resources.com/v0.9/guide/operation_processors.html
    # for some brief docs on "Operation Processors"
    class SetProcessor < JSONAPI::Processor

      # POST /sets/:id/relationships/materials
      # Gets the difference between what the materials already in this Aker::Set,
      # and what is in the request, and bulk inserts them onto the link table
      def create_to_many_relationships
        new_set_materials = Set.new(data) - model.material_ids
        bulk_insert!(model, new_set_materials)
        return JSONAPI::OperationResult.new(:no_content, result_options)
      end

      # PATCH /sets/:id/relationships/materials
      # Replaces all the materials in the Aker::Set with the ones in the request
      # Uses a bulk insert
      def replace_to_many_relationships
        model.set_materials.destroy_all
        bulk_insert!(model, data)
        return JSONAPI::OperationResult.new(:no_content, result_options)
      end

    private

      def resource_id
        params[:resource_id]
      end

      def relationship_type
        params[:relationship_type].to_sym
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
          { aker_set_id: aker_set.id, aker_material_id: material_id }
        end

        Aker::SetMaterial.bulk_insert(values: set_material_attrs)
      end

    end
  end
end