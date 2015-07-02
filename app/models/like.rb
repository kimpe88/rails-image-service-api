class Like < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :post, touch: true

  def self.like(user, post)
    if(Like.where(user: user, post: post).count == 0)
      Like.create!(user: user, post: post)
    else
      false
    end
  end
end
