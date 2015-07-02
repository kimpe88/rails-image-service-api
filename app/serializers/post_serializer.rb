class PostSerializer < ApplicationSerializer
  attributes :id, :image, :description, :author

  def image
    "/uploads/post/image/#{object.id}/file.png"
  end

  def author
    object.author_id
  end
end
