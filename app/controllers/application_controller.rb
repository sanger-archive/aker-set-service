class ApplicationController < JSONAPI::ResourceController

	check_authorization

	before_action :check_credentials

	rescue_from CanCan::AccessDenied do |exception|
		respond_to do |format|
			format.json { head :forbidden, content_type: 'text/html' }
	        format.html { redirect_to root_path, alert: exception.message }
	        format.js   { head :forbidden, content_type: 'text/html' }
		end
	end

private

	def apply_credentials
		RequestStore.store[:x_authorisation] = current_user
	end

    def current_user
        session['user']
    end

    def context
        {current_user: current_user}
    end

	def check_credentials
		if request.headers.to_h['HTTP_X_AUTHORISATION']
			begin
				secret_key = Rails.configuration.jwt_secret_key
				token = request.headers.to_h['HTTP_X_AUTHORISATION']
				payload, header = JWT.decode token, secret_key, true, { algorithm: 'HS256'}
				ud = payload["data"]
				session["user"] = {
					"user" => User.find_or_create_by(email: ud["user"]["email"]),
					"groups" => ud["groups"].map { |name| Group.find_or_create_by(name: name) },
				}

				rescue JWT::VerificationError => e
					render body: nil, status: :unauthorized
		    	rescue JWT::ExpiredSignature => e
		    		render body: nil, status: :unauthorized
	      	end
		else
			session["user"] = {
				"user" => User.find_or_create_by(email: "guest"),
				"groups" => [ Group.find_or_create_by(name: "world") ],
			}
		end
	end
end
