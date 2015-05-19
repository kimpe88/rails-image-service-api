class Following < ActiveRecord::Base
  belongs_to :follower, class_name: 'User', foreign_key: 'follower'
  belongs_to :followee, class_name: 'User', foreign_key: 'followee'
end
