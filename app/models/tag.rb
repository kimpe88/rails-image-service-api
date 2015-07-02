class Tag < ActiveRecord::Base
  validates :text, presence: true, uniqueness: true
  has_and_belongs_to_many :posts, touch: true
  has_and_belongs_to_many :comments, touch: true
end
