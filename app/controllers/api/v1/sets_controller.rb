class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < JSONAPI::ResourceController

      before_action :validate_uuids, only: [:update_relationship, :create_relationship]
      before_action :create_uuids, only: [:update_relationship, :create_relationship]

      # Fail request if the materials do not exist in materials service
      def validate_uuids
        unless Material.valid?(param_uuids)
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Invalid Material UUIDs' }]}, status: :unprocessable_entity
        end
      end

      def create_uuids
        param_uuids.each { |uuid| Aker::Material.find_or_create_by!(id: uuid) }
      end

      private

      def param_uuids
        params.require(:data).pluck(:id)
      end

    end
  end
end
