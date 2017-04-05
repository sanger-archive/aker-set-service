class MaterialNotFound < JSONAPI::Exceptions::Error
end

module Api
  module V1

    class SetsController < ApplicationController

      skip_authorization_check only: [:create, :index]

      before_action :pass_session_user, only: [:create]

      before_action :validate_uuids, only: [:update_relationship, :create_relationship]
      before_action :create_uuids, only: [:update_relationship, :create_relationship]
      before_action :check_lock, only: [:update, :destroy]

      before_action :authorise_read, only: [:show_relationship, :clone, :show]
      before_action :authorise_write, only: [:create_relationship, :update_relationship, :destroy_relationship, :update, :destroy]

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
        copy = set.clone(cloneparams[:name], session['user']['user'])
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

      def pass_session_user
        params[:user] = session['user']
      end

    end
  end
end
