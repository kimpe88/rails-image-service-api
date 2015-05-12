class Post < ActiveRecord::Base
  validates :image, :description, presence: true

  has_and_belongs_to_many :tags
  has_many :user_tags
  has_many :users, through: :user_tags


  # Make sure to always setup associantions before saving the post to
  # the database
  def self.create_post(post, tags = [], users_tagged = [])
    post.tags.concat(tags)
    post.users.concat(users_tagged)
    post.save
  end
end
