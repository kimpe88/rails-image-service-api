class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  # Disabled due to REST API is the only service provided
  # protect_from_forgery with: :exception

  # Handle exceptions in API specific way
  # TODO is this bad practice?
  rescue_from ::StandardError, with: :error_occurred

  protected
  # Deal with unhandled exceptions in an API way
  # Special case handling for RecordNotFound,
  # all other cases render internal server error status
  def error_occurred(exception)
    if exception.is_a?(ActiveRecord::RecordNotFound)
      status_code = 404
    else
      status_code = 500
    end
    response = {success: false}
    # Show more information if not in production
    if Rails.env.test? || Rails.env.development?
      response[:exception] = { message: exception.message, backtrace: exception.backtrace}
    end
    render json: response, status: status_code
  end

  private
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @authenticated_user = User.authenticate_with_token(token)
    end
  end
end
