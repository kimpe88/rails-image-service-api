class CreateUserTags < ActiveRecord::Migration
  def change
    create_table :user_tags do |t|
      t.string :text

      t.timestamps null: false
    end
  end
end
