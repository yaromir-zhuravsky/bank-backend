# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  def current_user
    _authentication_scheme, access_token = request.headers["Authorization"].to_s.split
    return unless TokensService.valid?(access_token)



    session = Session.find_by(uuid: TokensService.decode!(access_token).fetch(:sid))
    session.user if session.revoked_at == nil
  end

  def authenticate_request
    head :unauthorized unless current_user
  end
end
