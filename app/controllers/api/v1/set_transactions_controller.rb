module Api
  module V1
    class SetTransactionsController < ApplicationController
      attr_accessor :owner_id

      skip_authorization_check only: [:create, :index, :show]
      skip_credentials only: [:show, :index]

      def context
        super.merge({params: params})
      end

      private

      def resource_id
        params[:id]
      end



    end
  end
end