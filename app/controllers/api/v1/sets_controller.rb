class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < JSONAPI::ResourceController

      before_action :validate_uuids, only: [:update_relationship, :create_relationship]

      # Fail request if the materials do not exist in materials service
      def validate_uuids
        unless Material.valid?(param_uuids)
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Invalid Material UUIDs' }]}, status: :unprocessable_entity
        end
      end

      private

      def param_uuids
        params.require(:data).pluck(:id)
      end

    end
  end
end
