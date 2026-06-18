# frozen_string_literal: true

class ApplicationController < ActionController::API
  class ParamsInvalid < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super()
    end
  end

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ParamsInvalid, with: :params_invalid
  rescue_from OperationsService::DifferentCurrencies, with: :different_currencies

  private
  def record_invalid(e)
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end

  def record_not_found(e)
    render json: { errors: "#{e.model.downcase} not found" }, status: :not_found
  end

  def params_invalid(e)
    render json: { errors: e.errors }, status: :unprocessable_entity
  end

  def different_currencies(e)
    render json: { errors: e.errors }, status: :unprocessable_entity
  end

  def validate_params!(schema)
    result = schema.call(params.permit!.to_h)

    raise ParamsInvalid, result.errors.to_h unless result.success?

    result.to_h
  end
end
