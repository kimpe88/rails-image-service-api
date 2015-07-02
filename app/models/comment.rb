class Comment < ActiveRecord::Base
  include Taggable
  validates :comment, presence: true
  belongs_to :author, class_name: 'User', touch: true
  belongs_to :post, touch: true
  has_and_belongs_to_many :tags, touch: true
  has_many :user_tags
  has_many :tagged_users, through: :user_tags, class_name: 'User', source: :user
end

