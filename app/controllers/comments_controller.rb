class CommentsController < ApplicationController
  include TagSearchable
  include Pagingable
  before_filter :restrict_access, except: [:show, :post_comments]

  def show
    comment = Comment.find(params.require(:id))
    response = {
      success: true,
      result: CommentSerializer.new(comment, root: false)
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

    id =  comment.create_assoc_and_save(tags, user_tags)
    if id
      render json: { success: true, result: id }, status: :created
    else
      render json: {success: false}, status: :internal_server_error
    end
  end

  def update
    comment = Comment.find(params.require(:id))
    comment.comment = params[:comment] if params.has_key? :comment
    comment.tags = find_tags(params[:tags]) if params.has_key?(:tags)
    comment.tagged_users = find_user_tags(params[:user_tags]) if params.has_key?(:user_tags)

    if comment.save
      render json: { success: true }, status: :ok
    else
      render json: { success: false }, status: :internal_server_error
    end
  end

  def post_comments
    offset, limit = pagination_values
    comments = Comment.where(post_id: params.require(:id)).offset(offset).limit(limit)
    response = {
      success: true,
      offset: offset,
      limit: limit,
      result: ActiveModel::ArraySerializer.new(comments, each_serializer: CommentSerializer, root: false)
    }
    render json: response, status: :ok
  end


end
