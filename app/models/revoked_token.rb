class RevokedToken < ActiveRecord::Base

  validates :jti, presence: true, uniqueness: true
  validates :exp, presence: true
end