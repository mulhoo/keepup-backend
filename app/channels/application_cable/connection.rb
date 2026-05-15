module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      token = request.params[:token] || bearer_token
      return reject_unauthorized_connection unless token

      payload = JWT.decode(token, Rails.application.secret_key_base, true, algorithms: [ "HS256" ])[0]

      if payload["demo"]
        User.active.find_by(id: payload["sub"]) || reject_unauthorized_connection
      else
        User.active.find_by(id: payload["sub"], jti: payload["jti"]) || reject_unauthorized_connection
      end
    rescue JWT::DecodeError, JWT::ExpiredSignature
      reject_unauthorized_connection
    end

    def bearer_token
      request.headers["Authorization"]&.delete_prefix("Bearer ")
    end
  end
end
