class UserFollowing < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :following, class_name: 'User', touch: true
end
