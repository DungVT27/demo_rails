class Api::BaseController < ActionController::API
  # Rescuing ActiveRecord errors with structured JSON responses
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def record_not_found(exception)
    render json: { error: "Resource not found: #{exception.message}" }, status: :not_found
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  # Authenticater for API requests
  def authenticate_api_user!
    # Check X-User-Email header
    email = request.headers["X-User-Email"]
    @current_api_user = User.find_by(email: email) if email.present?

    # Fallback to user_id parameter for convenient curl testing
    if @current_api_user.blank? && params[:user_id].present?
      @current_api_user = User.find_by(id: params[:user_id])
    end

    if @current_api_user.blank?
      render json: {
        error: "Unauthorized access. Please supply a valid client email header 'X-User-Email' or 'user_id' query parameter."
      }, status: :unauthorized
    end
  end

  def current_user
    @current_api_user
  end
end
