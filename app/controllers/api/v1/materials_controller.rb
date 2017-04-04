module Api
  module V1
    class MaterialsController < ApplicationController
        skip_authorization_check only: :create

        before_action :authorise_read, only: [:get_related_resources]

    private
        def aker_set
            @aker_set ||= Aker::Set.find(params[:set_id])
        end

        def authorise_read
            authorize! :read, aker_set
        end
    end
  end
end

