# frozen_string_literal: true

module AuthenticationSchema
  Create = Dry::Schema.Params do
    required(:user).hash do
      required(:email).filled(:string)
      required(:password).filled(:string)
    end
  end
end
