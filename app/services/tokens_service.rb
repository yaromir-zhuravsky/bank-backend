# frozen_string_literal: true

class TokensService
  JWT_SECRET = ENV.fetch("JWT_SECRET")
  ALGORITHM = "HS256"

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

  def self.issue(payload, ttl:)
    encode!(
      {
        **payload,
        exp: ttl.from_now.to_i,
        jti: SecureRandom.uuid
      }
    )
  end

  def self.valid?(token)
    decode!(token)
    true
  rescue StandardError
    false
  end
end
