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
      unless(current_result.any?{|item| item.id == correct_result_item.id})
        puts "Item missing #{correct_result_item.inspect}"
      end
    end
  end
end

# Disable GC for tests for more reliable results
ENV["RUBY_DISABLE_GC"] = 'true'

# Turn off mysql cache
ActiveRecord::Base.connection.execute("SET GLOBAL query_cache_type=OFF;")

offset = 0
limit = 1000
results = []
user = User.all.sample
tmp = nil

# Don't use ActiveRecord cache either
ActiveRecord::Base.uncached do
  benchmark_results = AssertPerformance.benchmark_code("feed_unoptimized") do
    feed_users_ids = user.followings.pluck(:id)
    feed_users_ids << user.id
    Post.where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  benchmark_results = AssertPerformance.benchmark_code("feed_optimized") do
    feed_users_ids = UserFollowing.where(user_id: user.id).pluck(:following_id) << user.id
    Post.select(:id, :description, :author_id, :created_at).where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  check_results(results)


  puts "Benchmarking followers"
  results = []
  benchmark_results = AssertPerformance.benchmark_code("followers_unoptimized") do
    follower_ids = user.followers.pluck(:id)
    Post.where(author: follower_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  benchmark_results = AssertPerformance.benchmark_code("followers_optimized") do
    follower_ids = UserFollowing.where(following_id: user.id).pluck(:user_id)
    Post.select(:id, :description, :author_id, :created_at, :updated_at).where(author: follower_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"
  check_results(results)


  puts "Benchmarking followings"
  results = []
  tmp = nil
  benchmark_results = AssertPerformance.benchmark_code("followings_unoptimized") do
    following_ids = user.followings.pluck(:id)
    Post.where(author: following_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  benchmark_results = AssertPerformance.benchmark_code("followings_optimized") do
    following_ids = UserFollowing.where(user_id: user.id).pluck(:following_id)
    Post.select(:id, :description, :author_id, :created_at, :updated_at).where(author: following_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  results << benchmark_results[:results]
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  check_results(results)
end

# Turn on mysql cache
ActiveRecord::Base.connection.execute("SET GLOBAL query_cache_type=ON;")
