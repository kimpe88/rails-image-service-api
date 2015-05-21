class ChangeUserIdToAuthorIdInComment < ActiveRecord::Migration
  def change
    rename_column :comments, :user_id, :author_id
  end
end
