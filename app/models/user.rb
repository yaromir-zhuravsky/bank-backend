# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_one :customer, dependent: :restrict_with_error
  has_one :admin, dependent: :restrict_with_error
  has_many :sessions

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :uuid, uniqueness: true

  attribute :uuid, default: -> { SecureRandom.uuid }
end
