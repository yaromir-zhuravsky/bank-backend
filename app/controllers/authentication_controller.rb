# frozen_string_literal: true

class AuthenticationController < ApplicationController
  include Authenticatable

  before_action :authenticate_request, only: %i[logout me]

  def login
    validate_params!(SessionsSchema::Login) => { authentication: { email:, password: } }

    user = User.find_by(email:)
    if user&.authenticate(password)
      AuthenticationService.login!(user) => {access_token:, refresh_token:}

      render status: :ok, json: { access_token:, refresh_token: }
    else
      head :unauthorized
    end
  end

  def logout
    validate_params!(SessionsSchema::Logout) => { authentication: { refresh_token: } }

    if TokensService.valid?(refresh_token) && session.current_refresh_jti == TokensService.decode!(refresh_token).fetch(:jti)
      session = Session.find_by!(uuid: TokensService.decode!(refresh_token).fetch(:sid))
      AuthenticationService.logout!(session) if session.revoked_at == nil

      head :ok
    else
      head :unauthorized
    end
  end

  def refresh
    validate_params!(SessionsSchema::Refresh) => { authentication: { refresh_token: } }

    if TokensService.valid?(refresh_token)
      session = Session.find_by!(uuid: TokensService.decode!(refresh_token).fetch(:sid))
      if session.current_refresh_jti == TokensService.decode!(refresh_token).fetch(:jti)
        AuthenticationService.refresh!(session) => {access_token:, refresh_token:}

        render status: :ok, json: { access_token:, refresh_token: }
      end
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
