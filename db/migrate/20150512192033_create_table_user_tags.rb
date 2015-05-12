class CreateTableUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.belongs_to :post, index: true
      t.belongs_to :user, index: true
    end
  end
end
