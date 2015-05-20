
class PostsController < ApplicationController
  before_filter :restrict_access, except: :show

  def show
    begin
      response = {
        success: true,
        result: Post.find(params.require(:id))
      }
      render json: response
    rescue ActiveRecord::RecordNotFound
      render json: {success: false}, status: :not_found
    end
  end

  def create
    post = Post.new
    post.user = @authenticated_user
    post.description = params[:description]
    post.image = params[:image]
    tags = find_tags(params[:tags])
    user_tags = find_user_tags(params[:user_tags])

    if Post.create_post(post, tags, user_tags)
      render json: {success: true}, status: :created
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

  def update
    begin
      post = Post.find(params.require(:id))
      post.description = params[:description] if params.has_key?(:description)
      post.tags = find_tags(params[:tags]) if params.has_key?(:tags)
      post.tagged_users = find_user_tags(params[:user_tags]) if params.has_key?(:user_tags)

      if post.save
        render json: {success: true}, status: :ok
      else
        binding.pry
        render json: {success: false}, status: :internal_server_error
      end
    rescue ActiveRecord::RecordNotFound
      render json: {success: false}, status: :not_found
    end
  end


  private
  def find_tags(tags_param_arr)
    tags = []
    if(tags_param_arr)
      tags_param_arr.each do |tag|
        tags << Tag.find_or_create_by(text: tag)
      end
    end
    tags
  end

  def find_user_tags(user_tags_param_arr)
    # Find all users that have been tagged
    user_tags = []
    if(user_tags_param_arr)
      user_tags_param_arr.each do |user_tag|
        user = User.find_by(username: user_tag)
        user_tags << user if user
      end
    end
    user_tags
  end
end
