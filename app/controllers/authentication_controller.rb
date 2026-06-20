# frozen_string_literal: true

class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: [:login, :refresh]

  def login
    authentication_info = validate_params!(AuthenticationSchema::Login)[:authentication]

    user = User.find_by!(email: authentication_info[:email])
    if user.authenticate(authentication_info[:password])
      token_payload = { user_id: user.id }
      access_token = TokensService::Encode.perform(token_payload, 15.minutes.from_now.to_i)
      refresh_token = TokensService::Encode.perform(token_payload, 30.days.from_now.to_i)

      render status: :ok, json: { access_token:, refresh_token: }
    end
  end

  def logout
    authentication_info = validate_params!(AuthenticationSchema::Logout)[:authentication]

    refresh_token = authentication_info[:refresh_token]
    payload = TokensService::Decode.perform(refresh_token)
    RevokedToken.create!(jti: payload["jti"], exp: Time.at(payload["exp"]))
  end

  def refresh
    authentication_info = validate_params!(AuthenticationSchema::Refresh)[:authentication]

    refresh_token = authentication_info[:refresh_token]
    payload = TokensService::Decode.perform(refresh_token)
    token_payload = { user_id: payload["user_id"] }
    if RevokedToken.exists?(jti: payload["jti"])
      render status: :unauthorized
    else
      access_token = TokensService::Encode.perform(token_payload, 15.minutes.from_now.to_i)
      refresh_token = TokensService::Encode.perform(token_payload, 30.days.from_now.to_i)
      RevokedToken.create!(jti: payload["jti"], exp: Time.at(payload["exp"]))
      render status: :ok, json: { access_token: access_token, refresh_token: refresh_token }
    end
  end
end
