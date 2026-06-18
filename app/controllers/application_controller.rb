# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
  def record_invalid(e)
    render json: { errors: e.record.errors }, status: :unprocessable_entity
  end

  def record_not_found(e)
    render json: { errors: "#{e.model} not found" }, status: :not_found
  end
end
