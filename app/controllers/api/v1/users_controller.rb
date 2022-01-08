class Api::V1::UsersController < ApplicationController

  def create
    user = User.new(create_params)

    if user.save
      render json: user
    else
      render_bad_request(user.errors.full_messages)
    end
  end

  private

  def create_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
