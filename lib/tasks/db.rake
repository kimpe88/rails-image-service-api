namespace :db do
  desc "Creates a dataset to use for testing, takes size as an environment variable"
  task generate: :environment do
    size = ENV['size'] || 100
    size = size.to_i
    start_time = Time.now

    # Generate tags
    tags = []
    size.times do
      tags << FactoryGirl.create(:tag)
    end

    size.times do |i|
      if i % 10 == 0
        puts "#{i/size} % done (#{i} of #{size}) in #{(Time.now - start_time).round(4)} seconds"
      end
      user = FactoryGirl.create(:user)

      # Each users has 0 - 50 posts
      rand(0..50).times do
        # Create 0 - 5 tags and user_tags for each post
        user_tags = []
        post_tags = []
        rand(0..5).times do
          user_tags << User.all.sample
          post_tags << tags.sample
        end

        FactoryGirl.create(:post, author: user, tags: post_tags, tagged_users: user_tags)
      end

      # Each user makes 0 - 100 comments
      rand(0..100).times do
        FactoryGirl.create(:comment, author: user, post_id: Post.all.sample)
      end

      # Each user likes 0 - 200 posts
      rand(0..200).times do
        Like.like(user, Post.all.sample)
      end

      # Each user folows 0 - 100 other users
      rand(0..100).times do
        user.follow(User.all.sample)
      end
    end
    puts "Data generation completed in #{(Time.now - start_time).round(4)}"
  end
end
