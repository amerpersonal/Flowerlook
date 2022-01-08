class Api::V1::SightingsController < ApplicationController
  include Authentication::Authenticator

  before_action :authenticate, only: %i[create destroy]
  before_action :set_flower, only: %i[index create]
  before_action :set_sighting, only: %i[destroy]

  def index
    sightings = ListSightingsQuery.call(@flower, params)

    render json: sightings
  end

  def create
    sighting = @flower.sightings.new(sighting_params)
    sighting.user = logged_user

    if sighting.save
      render json: sighting
    else
      render_bad_request(*sighting.errors.full_messages)
    end
  end

  def destroy
    if @sighting
      @sighting.destroy
      render json: @sighting
    else
      render_not_found("Sighting not found")
    end
  end

  private

  def set_flower
    @flower = Flower.find_by_id(params[:flower_id])

    unless @flower
      render_not_found("Flower not found")
    end
  end

  def sighting_params
    params.require(:sighting).permit(:latitude, :longitude, :image, :user_id)
  end

  def set_sighting
    @sighting = Sighting.find_by(id: params[:id], user_id: logged_in_user_id)
  end
end
