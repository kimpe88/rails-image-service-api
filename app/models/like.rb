class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  def self.like(user, post)
    Like.create(user: user, post: post)
  end
end
