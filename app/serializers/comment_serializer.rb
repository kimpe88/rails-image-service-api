class CommentSerializer < ActiveModel::Serializer
  attributes :id, :comment, :author, :post

  def author
    object.author_id
  end

  def post
    object.post_id
  end
end
