class ApplicationController < JSONAPI::ResourceController
  include JWTCredentials

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json     { head :forbidden, content_type: 'text/html' }
      format.api_json { head :forbidden, content_type: 'application/vnd.api+json' }
      format.html     { redirect_to root_path, alert: exception.message }
      format.js       { head :forbidden, content_type: 'text/html' }
    end
  end

  before_action do
    # This should not be enabled on any public-facing environment
    Rack::MiniProfiler.authorize_request unless Rails.env.production?
  end

private

  def context
    { current_user: current_user }
  end

end
