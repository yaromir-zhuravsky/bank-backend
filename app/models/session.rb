class Session < ApplicationRecord
  belongs_to :user

  validates :uuid, uniqueness: true
  validates :current_refresh_jti,  uniqueness: true
  validates :expires_at, presence: true

  attribute :uuid, default: -> {SecureRandom.uuid}
end
