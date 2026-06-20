# frozen_string_literal: true

class OperationsController < ApplicationController
  def withdraw
    validated_params = validate_params!(OperationsSchema::Withdraw)
    operation_info = validated_params[:operation]
    account = Account.find_by!(number: operation_info[:from])
    OperationsService.withdraw(account, operation_info[:amount])

    head :ok
  end

  def deposit
    validated_params = validate_params!(OperationsSchema::Deposit)
    operation_info = validated_params[:operation]
    account = Account.find_by!(number: operation_info[:to])
    OperationsService.deposit(account, operation_info[:amount])

    head :ok
  end

  def transfer
    validated_params = validate_params!(OperationsSchema::Transfer)
    operation_info = validated_params[:operation]
    sender_account = Account.find_by!(number: operation_info[:from])
    receiver_account = Account.find_by!(number: operation_info[:to])
    OperationsService.transfer(sender_account, receiver_account, operation_info[:amount])

    head :ok
  end
end
