class ApplicationController < JSONAPI::ResourceController
	before_action :check_credentials

	private
	def check_credentials
		if request.headers.to_h['HTTP_X_AUTHORISATION']
			begin
			secret_key = Rails.configuration.jwt_secret_key
			token = request.headers.to_h['HTTP_X_AUTHORISATION']
			payload, header = JWT.decode token, secret_key, true, { algorithm: 'HS256'}
			session[:principle_user] = payload

			rescue JWT::VerificationError => e
				render body: nil, status: :unauthorized
	    	rescue JWT::ExpiredSignature => e
	    		render body: nil, status: :unauthorized
	      	end
		end
	end
end
