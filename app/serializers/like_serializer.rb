class LikeSerializer < ApplicationSerializer
  attributes :id, :user

  def user
    object.user_id
  end
end
