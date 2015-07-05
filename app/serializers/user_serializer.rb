class UserSerializer < ApplicationSerializer
  attributes :id, :username, :email, :birthdate, :description, :gender, :followings_count, :followers_count, :posts

  def posts
    object.posts.pluck(:id)
  end
end
