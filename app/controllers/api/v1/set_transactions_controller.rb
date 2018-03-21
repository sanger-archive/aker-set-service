module Api
  module V1
    class SetTransactionsController < ApplicationController

      include MaterialsEdition

      private

      def resource_id
        @resource_id ||= Aker::SetTransaction.find(params[:set_transaction_id] || params[:id]).aker_set_id
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

    end
  end
end