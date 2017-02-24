class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < JSONAPI::ResourceController

      before_action :validate_uuids, only: [:update_relationship, :create_relationship]
      before_action :create_uuids, only: [:update_relationship, :create_relationship]
      before_action :check_lock, only: [:update, :destroy]

      # This is the only way I found to prevent deleting materials from a set via 'patch'
      def check_lock
        if Aker::Set.find(params[:id]).locked?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Set locked' }]}, status: :unprocessable_entity
        end
      end

      # Fail request if the materials do not exist in materials service
      def validate_uuids
        unless Material.valid?(param_uuids)
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Invalid Material UUIDs' }]}, status: :unprocessable_entity
        end
      end

      def create_uuids
        param_uuids.each { |uuid| Aker::Material.find_or_create_by!(id: uuid) }
      end

      def clone
        cloneparams = clone_params
        set = Aker::Set.find(cloneparams[:set_id])
        copy = set.clone(cloneparams[:name])
        unless copy.save
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'The clone could not be created'}]}, status: :unprocessable_entity
        end
        # TODO: Ideally, render the complete JSONAPI version of the copy, with links, but I can't find any way to do that
        render json: { data: copy }, status: :created
      end

    private

      def clone_params
        {
          set_id: params.require(:set_id),
          name: params.require(:data).require(:attributes).require(:name),
        }
      end

      def param_uuids
        params.require(:data).pluck(:id)
      end

    end
  end
end
