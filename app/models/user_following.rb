class UserFollowing < ActiveRecord::Base
  belongs_to :user, touch: true, counter_cache: :followings_count
  belongs_to :following, class_name: 'User', touch: true, counter_cache: :followers_count
end
