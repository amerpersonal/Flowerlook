class ApplicationController < ActionController::API

  rescue_from ActionController::ParameterMissing do |e|
    render json: { errors: "Parameter missing or invalid: #{e.param}"}, status: :bad_request
  end

  def render_bad_request(*errors)
    render_error(:bad_request, *errors)
  end

  def render_not_found(*errors)
    render_error(:not_found, *errors)
  end

  def render_error(status, *errors)
    render json: { errors: errors }, status: status
  end

end
