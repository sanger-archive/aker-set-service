module Api
  module V1
    class SetTransactionsController < ApplicationController

      include MaterialsEdition

      before_action :check_done_transaction, only: [:update, :destroy, :update_relationship, 
        :create_relationship, :destroy_relationship]

      before_action :check_set_transaction_locked, only: [:create]
      before_action :authorise_create, only: [:create]

      private

      def check_done_transaction
        if set_transaction.done?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Transaction is done' }]}, status: :unprocessable_entity
        end
      end

      def check_set_transaction_locked
        if aker_set_from_creation_params.locked?
          return render json: { errors: [{ status: '422', title: 'Unprocessable entity', detail: 'Transaction is done' }]}, status: :unprocessable_entity
        end        
      end

      def resource_id
        @resource_id ||= set_transaction.aker_set_id
      end

      def aker_set_from_creation_params
        Aker::Set.find(params.fetch(:data, {}).fetch(:attributes, {}).fetch(:aker_set_id, {}))
      end

      def set_transaction
        @set_transaction ||= Aker::SetTransaction.find(params[:set_transaction_id] || params[:id])
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
        authorize! :write, aker_set
      end

      def authorise_create
        authorize! :write, aker_set_from_creation_params
      end

    end
  end
end