class PostsController < ApplicationController

  def create
    post_params = params.require(:post)
    post = Post.new
    post.description = post_params[:description]
    post.image = post_params[:image]
    tags = find_tags(post_params[:tags])
    user_tags = find_user_tags(post_params[:user_tags])

    if Post.create_post(post, tags, user_tags)
      render json: {success: true}, status: :created
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

  def update
    post_params = params.require(:post)
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
