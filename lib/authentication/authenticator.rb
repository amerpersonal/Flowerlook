module Authentication
  module Authenticator
    attr_reader :logged_user

    include Jwt

    def authenticate
      @logged_user = logged_in_user
      unauthorized_request unless @logged_user
    end

    def logged_in_user
      user_id = logged_in_user_id
      user_id && User.find(user_id)
    end

    def logged_in_user_id
      JsonWebToken.extract_user_id(extract_token)
    end

    def extract_token
      if request.headers && request.headers["Authorization"]
        request.headers["Authorization"].gsub("Bearer ", "")
      else
        nil
      end
    end

    def auth_request_header(token)
      "Bearer #{token}"
    end

    def logout(token)
      JsonWebToken.destroy_token(token)
    end

    def unauthorized_request
      render json: { error: "You're not authorized to access this resource" }, status: :unauthorized
    end
  end
end
