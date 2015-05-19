class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.timestamps null: false
      t.integer :follower, index: true
      t.integer :followee, intex: true
    end
  end
end
