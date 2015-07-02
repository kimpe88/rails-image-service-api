class UserTag < ActiveRecord::Base
  belongs_to :post, touch: true
  belongs_to :user, touch: true
  belongs_to :comment, touch: true
end
