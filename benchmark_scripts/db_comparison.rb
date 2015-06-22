require 'benchmark'
require 'assert_performance'
require 'pry'

# Make sure that each result set has the same items as the first one
# unessecary extra loop over first resultset but only for testing so
# it doesn't matter
def check_results(results)
  results.each do |result|
    raise "Not same amount of responses" unless result.size == results.first.size
  end

  results.first.each do |correct_result_item|
    results.each do |current_result|
      raise "Item missing" unless current_result.include? correct_result_item
    end
  end
end

# Disable GC for tests for more reliable results
ENV["RUBY_DISABLE_GC"] = 'true'

offset = 0
limit = 1000
results = []
user = User.all.sample
tmp = nil
benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    feed_users_ids = user.followings.pluck(:id)
    feed_users_ids << user.id
    tmp = Post.where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"


benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.where("author_id in (SELECT following_id FROM user_followings WHERE user_id = #{user.id}) OR author_id = #{user.id}").order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"


benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.where(author_id: user.id).union(Post.joins("LEFT JOIN `user_followings` ON `posts`.`author_id` = `user_followings`.`following_id` WHERE `user_followings`.`user_id` = #{user.id}")).order(created_at: :desc).limit(limit).offset(offset)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

check_results(results)


puts "Benchmarking followers"
results = []
benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    follower_ids = user.followers.pluck(:id)
    tmp = Post.where(author: follower_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.where("author_id in (select user_id from user_followings where following_id = #{user.id})").order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.joins("INNER JOIN user_followings ON posts.author_id = user_followings.user_id").where('user_followings.following_id = ?', user.id).distinct.order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"
check_results(results)


puts "Benchmarking followings"
results = []
benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    following_ids = user.followings.pluck(:id)
    tmp = Post.where(author: following_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.where("author_id in (SELECT following_id FROM user_followings WHERE user_id = ?)", user.id)
        .order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

benchmark_results = AssertPerformance.benchmark_code("Benchmarking feed optimization") do
  100.times do
    tmp = Post.joins("INNER JOIN user_followings ON posts.author_id = user_followings.following_id").where('user_followings.user_id = ?', user.id).distinct.order(created_at: :desc).offset(offset).limit(limit)
  end
  tmp
end
results << benchmark_results[:results]
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]}"

check_results(results)
