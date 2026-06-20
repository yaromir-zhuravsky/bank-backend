class RevokedToken < ActiveRecord::Base

  validates :jti, presence: true
  validates :exp, presence: true
end