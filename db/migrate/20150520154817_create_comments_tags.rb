class CreateCommentsTags < ActiveRecord::Migration
  def change
    create_table :comments_tags do |t|
      t.belongs_to :comment, index: true
      t.belongs_to :tag, index: true
    end
  end
end
