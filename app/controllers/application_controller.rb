class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #
  # Disabled due to REST API is the only service provided
  # protect_from_forgery with: :exception

  private
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @authenticated_user = User.authenticate_with_token(token)
    end
  end
end
