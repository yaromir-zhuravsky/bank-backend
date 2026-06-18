  module OperationsSchema
    Withdraw = Dry::Schema.Params do
      required(:operation).hash do
        required(:from).filled(:string)
        required(:amount).filled(:integer, gt?: 0)
      end
    end

    Deposit = Dry::Schema.Params do
      required(:operation).hash do
        required(:to).filled(:string)
        required(:amount).filled(:integer, gt?: 0)
      end
    end

    Transfer = Dry::Schema.Params do
      required(:operation).hash do
        required(:to).filled(:string)
        required(:from).filled(:string)
        required(:amount).filled(:integer, gt?: 0)
      end
    end
  end