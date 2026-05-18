module Demo
  class ApplicationController < ::ApplicationController
    skip_before_action :require_authentication
    before_action :load_demo_user
    before_action :require_demo_mode

    private

    def load_demo_user
      token = cookies[:keepup_auth] ||
              request.headers["Authorization"]&.delete_prefix("Bearer ")
      return unless token

      payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithms: [ "HS256" ])[0]
      return unless payload["demo"]

      @current_user = User.active.find_by(id: payload["sub"])
      @demo_session = true
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end

    def require_demo_mode
      render json: { error: "Not found" }, status: :not_found unless Rails.application.config.demo_mode
    end
  end
end
