module Api
  module V1
    class SetTransactionsController < ApplicationController

      include MaterialsEdition

      before_action :check_done_transaction, only: [:update, :destroy, :update_relationship, 
        :create_relationship, :destroy_relationship]

      before_action :check_set_transaction_locked, only: [:create]
      before_action :authorise_create, only: [:create]
        
      # This is the only way I found to prevent deleting materials from a set via 'patch'
      def check_lock
        unless is_set_create_transaction?
          if Aker::Set.find(resource_id).locked?
            return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Set is locked' }]}, status: :unprocessable_entity
          end
        end
      end

      def is_set_create_transaction?
        # If I am creating a new transaction and is a create operation
        return true if get_operation_from_creation_params == 'create'
        # If I am creating a new transaction but is not a create operation
        return false unless get_aker_set_transaction_id_from_params
        # If is already created
        (set_transaction.operation == 'create')
      end

      def check_done_transaction
        if set_transaction.done?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Transaction is done' }]}, status: :unprocessable_entity
        end
      end

      def check_set_transaction_locked
        # Only check the set is lock when it is not a creation operation, as we assume any new created set
        # is unlocked
        if !is_set_create_transaction? && get_aker_set_from_creation_params.locked?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Set is locked' }]}, status: :unprocessable_entity
        end
      end

      private

      def get_operation_from_creation_params
        return '' if params[:data].kind_of? Array
        params.fetch(:data, {}).fetch(:attributes, {}).fetch(:operation, "")
      end  

      def get_aker_set_from_creation_params
        Aker::Set.find(params.fetch(:data, {}).fetch(:attributes, {}).fetch(:aker_set_id, {}))
      end

      def get_aker_set_transaction_id_from_params
        params[:set_transaction_id] || params[:id]
      end

      def resource_id
        @resource_id ||= set_transaction.aker_set_id
      end

      def set_transaction
        @set_transaction ||= Aker::SetTransaction.find(get_aker_set_transaction_id_from_params)
      end

      def aker_set
        @aker_set ||= Aker::Set.find(resource_id)
      end

      def param_uuids
        params.require(:data).pluck(:id)
      end

      def authorise_read
        authorize! :read, aker_set
      end

      def authorise_write
        authorize! :write, aker_set unless is_set_create_transaction?
      end

      def authorise_create
        authorize! :write, get_aker_set_from_creation_params unless is_set_create_transaction?
      end

    end
  end
end