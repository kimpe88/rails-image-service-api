class UsersController < ApplicationController
  def sign_up
    user = User.new(signup_params)
    if user.save
      head :created
    else
      head :internal_server_error
    end
  end

  def log_in
    params =  login_params
    token = User.authenticate(params['username'], params['password'])
    if token
      render json: token, status: :ok
    else
      head :unauthorized
    end
  end

  # TODO should this also show posts, comments made by this user??
  def show
    begin
      user = User.find(params.require(:id))
      render json: user, status: :ok
    rescue ActiveRecord::RecordNotFound
      head :not_found
    end
  end

  private
  def login_params
    params.require(:user).permit(:username, :password)
  end

  def signup_params
    params.require(:user).permit(:username, :email, :password, :birthdate, :description, :gender)
  end
end
