class UserSerializer < ApplicationSerializer
  attributes :id, :username, :email, :birthdate, :description, :gender, :following_count, :followers_count

  has_many :posts
end
