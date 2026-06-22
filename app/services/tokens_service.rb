# frozen_string_literal: true

class TokensService
  JWT_SECRET = ENV.fetch("JWT_SECRET")
  ALGORITHM = "HS256"
  ACCESS_TOKEN_TTL = 1.minute
  REFRESH_TOKEN_TTL = 1.hour

  def self.encode!(payload)
    JWT.encode(
      payload,
      JWT_SECRET,
      ALGORITHM
    )
  end

  def self.decode!(token)
    payload, _headers = JWT.decode(
      token,
      JWT_SECRET,
      true,
      algorithm: ALGORITHM,
      verify_expiration: true
    )

    payload.deep_symbolize_keys
  end

  def self.token(user_payload = {}, ttl:)
    encode!(
      {
        **user_payload,
        exp: ttl.from_now.to_i,
        jti: SecureRandom.uuid
      }
    )
  end

  def self.tokens(user_payload = {})
    {
      access_token: token(user_payload, ttl: ACCESS_TOKEN_TTL),
      refresh_token: token(user_payload, ttl: REFRESH_TOKEN_TTL)
    }
  end

  def self.revoke!(token)
    payload = decode!(token)
    RevokedToken.create!(jti: payload[:jti], exp: Time.zone.at(payload[:exp]))
  end

  def self.valid?(token)
    decode!(token) => { jti: }
    !RevokedToken.exists?(jti:)
  rescue StandardError
    false
  end
end
