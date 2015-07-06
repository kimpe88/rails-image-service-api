require 'assert_performance'
require 'benchmark'
require 'pry'
# Turn off mysql cache
ActiveRecord::Base.connection.execute("SET GLOBAL query_cache_type=OFF;")

# Don't use ActiveRecord cache either
ActiveRecord::Base.uncached do
  offset = 0
  limit = 100
  # Caching users query
  puts "Uncached users query"
  benchmark_results= AssertPerformance.benchmark_code("Uncached users query") do
    User.order(:id).offset(offset).limit(limit)
  end
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  puts "Cached users query"
  benchmark_results = AssertPerformance.benchmark_code("Cached users query") do
    timestamp = User.maximum(:updated_at)
    # Cache query for better performanceê
    Rails.cache.fetch(["users",offset,limit,timestamp.to_i ].join('/')) do
      User.order(:id).offset(offset).limit(limit)
    end
  end
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  user = User.all.sample
  id = user.id
  puts "Uncached feed query"
  benchmark_results = AssertPerformance.benchmark_code("Uncached feed query") do
    feed_users_ids = UserFollowing.where(user_id: id).pluck(:following_id) << id
    feed_posts = Post.select(:id, :description, :author_id, :created_at, :updated_at).where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
  end
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

  puts "Cached feed query"
  benchmark_results = AssertPerformance.benchmark_code("Cached feed query") do
    timestamp = User.maximum(:updated_at)
    feed_posts = Rails.cache.fetch(["feed", id, offset, limit, timestamp.to_i].join('/')) do
      feed_users_ids = UserFollowing.where(user_id: id).pluck(:following_id) << id
      Post.select(:id, :description, :author_id, :created_at, :updated_at).where(author: feed_users_ids).order(created_at: :desc).offset(offset).limit(limit)
    end
  end
  puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"
end
# Turn on mysql cache
ActiveRecord::Base.connection.execute("SET GLOBAL query_cache_type=ON;")
