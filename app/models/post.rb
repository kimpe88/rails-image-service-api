class Post < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :user_tags
end
