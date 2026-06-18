  module OperationsService
    class Withdraw
      def self.perform(account, amount)
        ActiveRecord::Base.transaction do
          operation = Operation.create!
          Transaction.create!(account_id: account.id, operation_id: operation.id, amount: -amount)
          account.deduct!(amount)
        end
      end
    end

    class Deposit
      def self.perform(account, amount)
        ActiveRecord::Base.transaction do
          operation = Operation.create!
          Transaction.create!(account_id: account.id, operation_id: operation.id, amount:)
          account.add!(amount)
        end
      end
    end

    class Transfer
      def self.perform(sender_account, receiver_account, amount)
        ActiveRecord::Base.transaction do
          operation = Operation.create!
          Transaction.create!(account_id: sender_account.id, operation_id: operation.id, amount: -amount)
          sender_account.deduct!(amount)
          Transaction.create!(account_id: receiver_account.id, operation_id: operation.id, amount:)
          receiver_account.add!(amount)
        end
      end
    end
  end