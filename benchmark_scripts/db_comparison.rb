require 'benchmark'

# Make sure that each result set has the same items as the first one
# unessecary extra loop over first resultset but only for testing so
# it doesn't matter
def check_results(results)
  results.each do |result|
    raise "Not same amount of responses" unless result.size == results.first.size
  end

  results.each do |current_result|
    results.first.each do |correct_result_item|
      raise "Item missing" unless current_result.include? correct_result_item
    end
  end
end

offset = 0
limit = 1000
user = User.all.sample
puts "Benchmarking feed optimization"
results = []
Benchmark.bm(10) do |x|
  x.report("Unoptimized") do
    feed_users_ids = user.followings.pluck(:id)
    feed_users_ids << user.id
    results << Post.where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  x.report("Nested select") do
    results << Post.where("author_id in (SELECT following_id FROM user_followings WHERE user_id = #{user.id}) OR author_id = #{user.id}").order(created_at: :desc).offset(offset).limit(limit)
  end
  x.report("Inner join") do
    results << Post.joins("LEFT JOIN user_followings ON posts.author_id = user_followings.following_id").where('user_followings.user_id = ? or posts.author_id = ?', user.id, user.id).distinct.order(created_at: :desc).offset(offset).limit(limit)
  end
end
check_results(results)

results = []
puts "Benchmarking followers optimization"
Benchmark.bm(10) do |x|
  x.report("Unoptimized") do
    follower_ids = user.followers.pluck(:id)
    results << Post.where(author: follower_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  x.report("Custom qury") do
    results << Post.where("author_id in (select user_id from user_followings where following_id = #{user.id})").order(created_at: :desc).offset(offset).limit(limit)
  end

  x.report("Inner join") do
    results << Post.joins("INNER JOIN user_followings ON posts.author_id = user_followings.user_id").where('user_followings.following_id = ?', user.id).distinct.order(created_at: :desc).offset(offset).limit(limit)
  end
end
check_results(results)

results = []
puts "Benchmarking following_posts"
Benchmark.bm(10) do |x|
  x.report("Custom qury") do
    results << Post.where("author_id in (SELECT following_id FROM user_followings WHERE user_id = ?)", user.id)
      .order(created_at: :desc).offset(offset).limit(limit)
  end

  x.report("Inner join") do
    results << Post.joins("INNER JOIN user_followings ON posts.author_id = user_followings.following_id").where('user_followings.user_id = ?', user.id).distinct.order(created_at: :desc).offset(offset).limit(limit)
  end
end
check_results(results)
