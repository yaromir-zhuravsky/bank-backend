# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action authenticate_request
  end

  def current_user
    _authentication_scheme, access_token = request.headers["Authorization"].to_s.split
    User.find_by(uuid: TokensService.decode!(access_token)["user_uuid"])
  end

  private

  def authenticate_request
    render status: :unauthorized unless current_user
  end
end
