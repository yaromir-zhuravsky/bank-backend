# frozen_string_literal: true

class TokensService
  JWT_SECRET = ENV.fetch("JWT_SECRET")
  ENCRYPTION_ALGORITHM = "HS256"


  def self.encode!(payload)
    JWT.encode(payload, JWT_SECRET, ENCRYPTION_ALGORITHM)
  end

  def self.decode!(token)
    JWT.decode(token, JWT_SECRET, ENCRYPTION_ALGORITHM)[0].deep_symbolize_keys
  end

  def self.revoke!(token)
    payload = decode!(token)
    RevokedToken.create!(jti: payload[:jti], exp: Time.at(payload[:exp]))
  end

  def self.access_token(payload = {})
    encode!({**payload, exp: 15.minutes.from_now.to_i})
  end

  def self.refresh_token(payload = {})
    encode!({
            **payload,
            exp: 30.days.from_now.to_i,
            jti: SecureRandom.uuid,
           }
    )
  end

  def self.revoked?(token)
    jti = decode!(token)[:jti]
    RevokedToken.exists?(jti:)
  end
end
