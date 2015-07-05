class AddCounterColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :followings_count, :integer, default: 0
    add_column :users, :followers_count, :integer, default: 0
  end
end
