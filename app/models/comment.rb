class Comment < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :user_tags
  has_many :tagged_users, through: :user_tags, class_name: 'User', source: :user

end

