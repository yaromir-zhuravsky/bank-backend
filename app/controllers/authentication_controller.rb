# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def login
    user_info = validate_params!(AuthenticationSchema::Create)[:user]

    user = User.find_by!(email: user_info[:email])
    if user.authenticate(user_info[:password])
      token_payload = { user_id: user.id }
      access_token = JwtService::Encode.perform(token_payload, 15.minutes.from_now.to_i)
      refresh_token = JwtService::Encode.perform(token_payload, 30.days.from_now.to_i)

      render status: :ok, json: { access_token:, refresh_token: }
    else
      render status: :unauthorized, json: { error: "invalid email or password" }
    end
  end
end
