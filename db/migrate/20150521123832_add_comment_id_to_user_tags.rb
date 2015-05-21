class AddCommentIdToUserTags < ActiveRecord::Migration
  def change
    add_reference :user_tags, :comment, index: true
  end
end
