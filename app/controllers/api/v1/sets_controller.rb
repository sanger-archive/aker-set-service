class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < ApplicationController

      attr_accessor :owner_id
      skip_authorization_check only: [:create, :index, :show]
      skip_credentials only: [:show, :index]

      before_action :validate_uuids, only: [:update_relationship, :create_relationship]
      before_action :create_uuids, only: [:update_relationship, :create_relationship]
      before_action :check_lock, only: [:update, :destroy, :update_relationship, :create_relationship, :destroy_relationship]

      before_action :authorise_write, only: [:create_relationship, :update_relationship, :destroy_relationship, :update, :destroy]
      before_action :set_owner, only: :create

      def set_owner
        self.owner_id = params.fetch(:data).dig("attributes", "owner_id")
        params["data"]["attributes"].delete("owner_id") if self.owner_id
      end

      # This is the only way I found to prevent deleting materials from a set via 'patch'
      def check_lock
        if Aker::Set.find(resource_id).locked?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Set is locked' }]}, status: :unprocessable_entity
        end
      end

      # Fail request if the materials do not exist in materials service
      def validate_uuids
        unless Material.valid?(param_uuids)
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Invalid Material UUIDs' }]}, status: :unprocessable_entity
        end
      end

      def create_uuids
        existing_materials = Aker::Material.where(id: param_uuids).pluck(:id)
        materials_to_create = existing_materials - param_uuids
        Aker::Material.bulk_insert(values: materials_to_create)
      end

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

      def context
        super.merge({owner_id: owner_id})
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
