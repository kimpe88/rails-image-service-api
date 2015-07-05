require 'assert_performance'
require 'benchmark'
require 'pry'

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
  timestamp = Post.maximum(:updated_at)
  # Cache query for better performanceê
  Rails.cache.fetch(["users",offset,limit,timestamp.to_i ].join('/')) do
    User.order(:id).offset(offset).limit(limit)
  end
end
puts "#{benchmark_results[:benchmark][:name]} average: #{benchmark_results[:benchmark][:average]} with std deviation of #{benchmark_results[:benchmark][:standard_deviation]} memory #{benchmark_results[:benchmark][:memory]}"

