class Api::V1::SessionsController < ApplicationController
  include Authentication::Authenticator
  include Validators::Common
  include Jwt

  before_action :authenticate, only: %i[show destroy]

  def create
    user = User.find_by(username: params[:username])
    device_id = params[:device_id]

    if valid_device_id?(device_id) && user && user.authenticate(params[:password])
      token = JsonWebToken.create_token(user, device_id)
      render json: { user_id: user.id, token: token }
    else
      render_bad_request("Invalid username, password or device_id")
    end
  end

  def destroy
    if logout(extract_token)
      render json: { success: true }, status: :ok
    else
      render_bad_request("Invalid token")
    end
  end

  def show
    if logged_in_user
      render json: logged_in_user
    else
      render_not_found("You are not logged in")
    end
  end
end