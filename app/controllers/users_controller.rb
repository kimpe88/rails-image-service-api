class UsersController < ApplicationController
  include Pagingable
  before_filter :restrict_access, except: [:sign_up, :log_in, :feed]
  def sign_up
    user = User.new(signup_params)
    if user.save
      response = {success: true, result: user.id}
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
    user = User.find(params.require(:id))
    response = { success: true, result: UserSerializer.new(user, root: false) }
    render json: response , status: :ok
  end

  def index
    offset, limit = pagination_values
    users = User.order(:id).offset(offset).limit(limit)
    response = {success: true, result: ActiveModel::ArraySerializer.new(users, each_serializer: UserSerializer, root: false), offset: offset, limit: limit}
    render json: response , status: :ok
  end

  def following
    offset, limit = pagination_values
    user = User.find(params.require(:id))
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: user.followings.offset(offset).limit(limit)
    }

    # Dirty hack to only return the id and username for each follower
    # Override as json for this specifc instance to not have to build the json manually
    response[:result].define_singleton_method(:as_json, -> (args) { super(only: [:id, :username], include: [], methods: []) })
    render json: response, status: :ok
  end

  def followers
    offset, limit = pagination_values
    user = User.find(params.require(:id))
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: user.followers.offset(offset).limit(limit).select([:id, :username])
    }
    # Dirty hack to only return the id and username for each follower
    # Override as json for this specifc instance to not have to build the json manually
    response[:result].define_singleton_method(:as_json, -> (args) { super(only: [:id, :username], include: [], methods: []) })
    render json: response , status: :ok
  end

  def following_posts
    user = User.find(params.require(:id))
    offset, limit = pagination_values
    following_ids = user.followings.pluck(:id)
    following_posts = Post.where(author: following_ids).order(created_at: :desc).offset(offset).limit(limit)
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: following_posts
    }
    render json: response, status: :ok
  end

  def followers_posts
    user = User.find(params.require(:id))
    offset, limit = pagination_values
    follower_ids = user.followers.pluck(:id)
    follower_posts = Post.where(author: follower_ids).order(created_at: :desc).offset(offset).limit(limit)
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: follower_posts
    }
    render json: response, status: :ok
  end

  # A user's feed is all posts made by that user or any of the users it follows
  # ordered by time of posting
  def feed
    user = User.find(params.require(:id))
    offset, limit = pagination_values
    feed_posts = Post.where("author_id in (SELECT following_id FROM user_followings WHERE user_id = #{user.id}) OR author_id = #{user.id}")
      .order(created_at: :desc).offset(offset).limit(limit)
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: feed_posts
    }
    render json: response, status: :ok
  end

  private
  def login_params
    params.permit(:username, :password)
  end

  def signup_params
    params.permit(:username, :email, :password, :birthdate, :description, :gender)
  end
end
