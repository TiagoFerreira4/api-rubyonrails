# app/controllers/concerns/error_handler.rb
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from ArgumentError, with: :argument_error # For bad enum values etc.
  end

  private

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def user_not_authorized(exception)
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end

  def argument_error(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end