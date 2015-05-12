class AddUserToUserTag < ActiveRecord::Migration
  def change
    change_table :user_tags do |t|
      t.belongs_to :user, index: true
      t.belongs_to :post, index: true
    end

  end
end
