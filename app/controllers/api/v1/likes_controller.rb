class Api::V1::LikesController < ApplicationController
  include Authentication::Authenticator

  before_action :authenticate, only: %i[create destroy]
  before_action :set_like, only: %i[destroy]

  def create
    like = Like.new(sighting_id: params[:sighting_id], user_id: logged_in_user_id)

    if like.save
      render json: like
    else
      render_bad_request(like.errors)
    end
  end

  def destroy
    if @like
      @like.destroy
      render json: @like
    else
      render_not_found("Like not found")
    end
  end

  private

  def set_like
    @like = Like.find_by(sighting_id: params[:sighting_id], user_id: logged_in_user_id)
  end

end