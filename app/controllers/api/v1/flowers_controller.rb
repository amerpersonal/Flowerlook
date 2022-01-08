class Api::V1::FlowersController < ApplicationController
  before_action :set_flower, only: %i[show]

  def index
    flowers = ListFlowersQuery.call(params)
    render json: flowers
  end

  def show
    if @flower
      render json: @flower
    else
      render_not_found("Flower not found")
    end
  end

  private

  def set_flower
    @flower = Flower.find_by(params[:id])
  end

end
