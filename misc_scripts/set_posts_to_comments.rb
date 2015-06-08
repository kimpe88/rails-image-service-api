Comment.all.each do |comment|
  comment.post = Post.order("RAND()").first
  comment.save!
end
