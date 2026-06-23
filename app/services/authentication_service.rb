# frozen_string_literal: true

class AuthenticationService
  ACCESS_TOKEN_TTL = 1.minute
  REFRESH_TOKEN_TTL = 1.hour
  
  def self.login!(user)
    session = Session.new(user:)
    issue_tokens(session) => { access_token:, refresh_token: }
    session.update(current_refresh_jti: TokensService.decode!(refresh_token).fetch(:jti),
                   expires_at: Time.at(TokensService.decode!(refresh_token).fetch(:exp)))
    session.save!
    { access_token:, refresh_token: }
  end

  def self.logout!(session)
    session.update!(revoked_at: Time.zone.now)
  end

  def self.refresh!(session)
    issue_tokens(session) => { access_token:, refresh_token: }
    session.update!(current_refresh_jti: TokensService.decode!(refresh_token).fetch(:jti))
    { access_token:, refresh_token: }
  end

  private 
  
  def self.issue_tokens(session)
    {
      access_token: TokensService.issue({ sid: session.uuid }, ttl: ACCESS_TOKEN_TTL),
      refresh_token: TokensService.issue({ sid: session.uuid }, ttl: REFRESH_TOKEN_TTL)
    }
  end
end
