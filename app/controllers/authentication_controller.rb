# frozen_string_literal: true

class AuthenticationController < ApplicationController
  include Authenticatable

  skip_before_action :authenticate_request, only: %i[login refresh]

  def login
    validate_params!(AuthenticationSchema::Login) => { authentication: { email:, password: } }
    user = User.find_by(email:)
    if user&.authenticate(password)
      payload = { user_uuid: user.uuid }
      TokensService.tokens(payload) => { access_token:, refresh_token: }

      render status: :ok, json: { access_token:, refresh_token: }
    else
      head :unauthorized
    end
  end

  def logout
    validate_params!(AuthenticationSchema::Logout) => { authentication: { refresh_token: } }
    _authentication_scheme, access_token = request.headers["Authorization"].to_s.split
    if TokensService.valid?(refresh_token)
      TokensService.revoke!(refresh_token)
      TokensService.revoke!(access_token)
      head :ok
    else
      head :unauthorized
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
      head :unauthorized
    end
  end

  def me
    render status: :ok, json: {
      user: {
        uuid: current_user.uuid,
        email: current_user.email
      }
    }
  end
end
