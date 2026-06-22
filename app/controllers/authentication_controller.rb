# frozen_string_literal: true

class AuthenticationController < ApplicationController
  def login
    validate_params!(AuthenticationSchema::Login) => { authentication: { email:, password: } }
    user = User.find_by(email:)
    if user&.authenticate(password)
      payload = { user_uuid: user.uuid }
      TokensService.tokens(payload) => { access_token:, refresh_token: }

      render status: :ok, json: { access_token:, refresh_token: }
    else
      render status: :unauthorized
    end
  end

  def logout
    validate_params!(AuthenticationSchema::Logout) => { authentication: { refresh_token: } }
    _authentication_scheme, access_token = request.headers["Authorization"].to_s.split

    if TokensService.valid?(refresh_token) && TokensService.valid?(access_token)
      TokensService.revoke!(refresh_token)
      TokensService.revoke!(access_token)
      head :ok
    else
      render status: :unauthorized
    end
  end

  def refresh
    validate_params!(AuthenticationSchema::Refresh) => { authentication: { refresh_token: } }

    if TokensService.valid?(refresh_token)
      payload = TokensService.decode!(refresh_token)
      TokensService.revoke!(refresh_token)
      TokensService.tokens(payload) => { access_token:, refresh_token: }

      render status: :ok, json: { access_token:, refresh_token: }
    else
      render status: :unauthorized
    end
  end
end
