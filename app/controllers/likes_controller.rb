class LikesController < ApplicationController
  before_filter :restrict_access, except: :index

  def create
    begin
      post = Post.find(params.require(:id))
      Like.like(@authenticated_user, post)
      render json: {success: true}, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: {success: false}, status: :bad_request
    end
  end

  def index
    begin
      post = Post.find(params.require(:id))
      response = {
        success: true,
        result: post.likes
      }
      render json: response, status: :ok
    rescue ActiveRecord::RecordNotFound
      render json: {success: false}, status: :not_found
    end
  end
end
