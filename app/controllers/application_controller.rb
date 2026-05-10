class ApplicationController < ActionController::API
  include Pundit::Authorization

  before_action :require_authentication

  rescue_from Pundit::NotAuthorizedError, with: :pundit_not_authorized

  private

  def pundit_not_authorized
    render json: { error: "Not authorized" }, status: :forbidden
  end

  private

  def current_user
    @current_user ||= authenticate_token
  end

  def demo_session?
    @demo_session == true
  end

  def require_authentication
    render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
  end

  def authenticate_token
    token = bearer_token
    return nil unless token

    payload = JWT.decode(token, secret_key, true, algorithm: "HS256")[0]

    if payload["demo"]
      @demo_session = true
      User.active.find_by(id: payload["sub"])
    else
      User.active.find_by(id: payload["sub"], jti: payload["jti"])
    end
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def bearer_token
    request.headers["Authorization"]&.delete_prefix("Bearer ")
  end

  def secret_key
    Rails.application.secret_key_base
  end
end
