
class PostsController < ApplicationController
  include TagSearchable
  before_filter :restrict_access, except: :show

  def show
    post = Post.find(params.require(:id))
    if stale? post
      response = {
        success: true,
        result: PostSerializer.new(post, root: false)
      }
      render json: response
    end
  end

  def create
    post = Post.new
    post.author = @authenticated_user
    post.description = params[:description]
    post.image = params[:image]
    tags = find_tags(params[:tags])
    user_tags = find_user_tags(params[:user_tags])
    id = post.create_assoc_and_save(tags, user_tags)
    if id
      render json: {success: true, result: id}, status: :created
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

  def update
    post = Post.find(params.require(:id))
    post.description = params[:description] if params.has_key?(:description)
    post.tags = find_tags(params[:tags]) if params.has_key?(:tags)
    post.tagged_users = find_user_tags(params[:user_tags]) if params.has_key?(:user_tags)

    if post.save
      render json: {success: true}, status: :ok
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

end
