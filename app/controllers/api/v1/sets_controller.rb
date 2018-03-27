class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < ApplicationController

      include MaterialsEdition

      def clone
        cloneparams = clone_params
        set = Aker::Set.find(cloneparams[:set_id])
        copy = set.clone(cloneparams[:name], current_user.email)
        unless copy.save
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'The clone could not be created'}]}, status: :unprocessable_entity
        end
        jsondata = JSONAPI::ResourceSerializer.new(Api::V1::SetResource).serialize_to_hash(Api::V1::SetResource.new(copy, nil))
        render json: jsondata, status: :created
      end

    private

      def aker_set
        @aker_set ||= Aker::Set.find(params[:set_id] || params[:id])
      end

      def clone_params
        {
          set_id: params.require(:set_id),
          name: params.require(:data).require(:attributes).require(:name),
        }
      end

      def param_uuids
        params.require(:data).pluck(:id)
      end

      def authorise_read
        authorize! :read, aker_set
      end

      def authorise_write
        authorize! :write, aker_set
      end

      def resource_id
        params[:id] || params[:set_id]
      end

    end
  end
end
