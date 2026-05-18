module TokenIssuable
  extend ActiveSupport::Concern

  private

  def issue_token!(user)
    payload = {
      sub: user.id,
      jti: SecureRandom.uuid,
      exp: 24.hours.from_now.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end
end
