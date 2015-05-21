class CommentsController < ApplicationController
  include TagSearchable
  before_filter :restrict_access, except: [:show, :post_comments]

  def show
    comment = Comment.find(params.require(:id))
    response = {
      success: true,
      result: comment
    }
    render json: response, status: :ok
  end

  def create
    comment = Comment.new
    comment.comment = params.require(:comment)
    comment.post = Post.find(params.require(:post))
    comment.author = @authenticated_user
    tags = find_tags(params[:tags])
    user_tags = find_user_tags(params[:user_tags])

    if comment.create_assoc_and_save(tags, user_tags)
      render json: { success: true }, status: :created
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

  def update

  end

  def post_comments

  end


end
