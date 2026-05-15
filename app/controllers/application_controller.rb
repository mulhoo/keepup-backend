class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::Cookies

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
    return render json: { error: "Unauthorized" }, status: :unauthorized unless current_user

    if current_user.institution_roles.where("end_date IS NOT NULL AND end_date <= ?", Date.current).exists?
      current_user.institution_roles.update_all(active: false)
      current_user.soft_delete!
      clear_auth_cookie
      render json: { error: "Access has expired" }, status: :unauthorized
    end
  end

  def authenticate_token
    token = bearer_token
    return nil unless token

    payload = JWT.decode(token, secret_key, true, algorithms: [ "HS256" ])[0]

    if payload["demo"]
      @demo_session = true
      User.active.find_by(id: payload["sub"])
    else
      User.active.find_by(id: payload["sub"], jti: payload["jti"])
    end
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def current_district
    @current_district ||= begin
      slug = request.headers["X-District-Subdomain"].presence
      District.find_by_subdomain(slug) if slug
    end
  end

  def set_auth_cookie(token)
    cookies[:keepup_auth] = {
      value:     token,
      httponly:  true,
      secure:    Rails.env.production?,
      same_site: :lax,
      expires:   30.days.from_now,
      path:      "/"
    }
  end

  def clear_auth_cookie
    cookies.delete(:keepup_auth, path: "/")
  end

  def bearer_token
    cookies[:keepup_auth] ||
      request.headers["Authorization"]&.delete_prefix("Bearer ")
  end

  def secret_key
    Rails.application.secret_key_base
  end
end
