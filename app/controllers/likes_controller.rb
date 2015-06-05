class LikesController < ApplicationController
  before_filter :restrict_access, except: :post_likes

  def create
    post = Post.find(params.require(:id))
    Like.like(@authenticated_user, post)
    render json: {success: true}, status: :created
  end

  def post_likes
    post = Post.find(params.require(:id))
    response = {
      success: true,
      result: ActiveModel::ArraySerializer.new(post.likes, each_serializer: LikeSerializer, root: false)
    }
    render json: response, status: :ok
  end
end
