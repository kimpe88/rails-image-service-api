class Post < ActiveRecord::Base
  validates :image, :description, presence: true

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :user_tags
  has_many :likes
  has_many :tagged_users, through: :user_tags, class_name: 'User', source: :user

  mount_base64_uploader :image, ImageUploader


  # Make sure to always setup associantions before saving the post to
  # the database
  def self.create_post(post, tags = [], users_tagged = [])
    post.tags.concat(tags)
    post.tagged_users.concat(users_tagged)
    post.save
  end
end
