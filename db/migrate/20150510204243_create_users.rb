class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :password
      t.date :birthdate
      t.text :description
      t.string :gender

      t.timestamps null: false
    end
  end
end
