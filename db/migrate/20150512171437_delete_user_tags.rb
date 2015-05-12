class DeleteUserTags < ActiveRecord::Migration
  def change
    drop_table :user_tags do |t|

    end
  end
end
