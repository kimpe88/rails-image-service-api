class Post < ActiveRecord::Base
  validates :image, :description, presence: true

  belongs_to :user
  has_and_belongs_to_many :tags
  has_many :user_tags
  has_many :likes
  has_many :tagged_users, through: :user_tags, class_name: 'User', source: :user

  mount_base64_uploader :image, ImageUploader

  # Sets up correct associations for a post
  # @param {Array} tags - Tags for the post
  # @param {Array} users_tagged - Users to be tagged in the post
  def create_assoc_and_save(tags = [], users_tagged = [])
    tags = [tags] unless tags.respond_to?('each')
    users_tagged = [users_tagged] unless users_tagged.respond_to?('each')
    self.tags = tags
    begin
      users_tagged.each do |user|
        UserTag.create!(post: self, user: user)
      end
      self.save!
    rescue ActiveRecord::RecordNotSaved
      return false
    end
    true
  end
end
