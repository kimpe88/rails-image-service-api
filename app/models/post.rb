class Post < ActiveRecord::Base
  include Taggable
  validates :image, :description, presence: true

  belongs_to :author, class_name: 'User'
  has_and_belongs_to_many :tags
  has_many :user_tags
  has_many :comments
  has_many :likes
  has_many :tagged_users, through: :user_tags, class_name: 'User', source: :user

  mount_base64_uploader :image, ImageUploader

  def image_url
    "/uploads/post/image/#{self.id}/file.png"
  end

  def as_json(options = {})
    super({ except: [:image, :created_at, :updated_at], methods: :image_url })
  end
end
