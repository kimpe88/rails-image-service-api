class UsersController < ApplicationController
  def sign_up
    user = User.new(signup_params)
    if user.save
      response = {success: true}
      render json: response, status: :created
    else
      response = {success: false}
      render json: response, status: :internal_server_error
    end
  end

  def log_in
    params =  login_params
    token = User.authenticate(params['username'], params['password'])
    if token
      response = {success: true, result: token}
      render json: response, status: :ok
    else
      response = {success: false}
      render json: response, status: :unauthorized
    end
  end

  def show
    begin
      user = User.find(params.require(:id))
      response = {success: true, result: user}
      render json: response , status: :ok
    rescue ActiveRecord::RecordNotFound
      response = {success: false}
      render json: response, status: :not_found
    end
  end

  def index
    offset = params.require(:offset).to_i
    # Set limit to supplied value if any otherwise default to 10
    # max limit 100 per request
    limit =  (params[:limit] || 10).to_i
    limit = 100 if limit > 100
    users = User.order(:id).offset(offset).limit(limit)
    response = {success: true, result: users, offset: offset, limit: limit}
    render json: response, status: :ok
  end

  private
  def login_params
    params.require(:user).permit(:username, :password)
  end

  def signup_params
    params.require(:user).permit(:username, :email, :password, :birthdate, :description, :gender)
  end
end
