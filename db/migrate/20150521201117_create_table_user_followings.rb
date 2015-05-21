class CreateTableUserFollowings < ActiveRecord::Migration
  def change
    create_table :user_followings do |t|
      t.integer :user_id, index:true
      t.integer :following_id, index:true
    end
  end
end
