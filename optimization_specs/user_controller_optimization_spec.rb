require 'rails_helper'
require 'assert_performance'

RSpec.describe UsersController, type: :request do
  it 'should benchmark performance for users' do
     results = AssertPerformance.benchmark_code("users") do
       # Hack cause user tokens dissappear inside benchmark
       # probably due to the ActiveRecord transaction used to
       # remove any changes to db between runs
       @user = FactoryGirl.create(:user)
       token = User.authenticate(@user.username, 'password')
       token = ActionController::HttpAuthentication::Token.encode_credentials(token)
       get "/users", {offset: 0}, authorization: token
       expect(response.status).to be 200
    end
     puts results
  end

  it 'should profile memory for users' do
    class UsersController
      # Alias index method if this is the first time we're monkey patching
      if !self.method_defined?(:old_index)
        puts "Aliasing index"
        alias_method :old_index, :index
      end

      def index
        puts "patched index"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::MEMORY
        RubyProf.start
        # Call the real index method to profile it
        self.old_index
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/users_memory_profile.out.app', 'w+'))
      end
    end

    # Get users to obtain profile data
    get "/users", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end

  it 'should profile cpu for users' do
    class UsersController
      # Alias index method if this is the first time we're monkey patching
      if !self.method_defined?(:old_index)
        puts "Aliasing index"
        alias_method :old_index, :index
      end

      def index
        puts "patched index"
        GC.disable
        RubyProf.measure_mode = RubyProf::CPU_TIME
        RubyProf.start
        # Call the real index method to profile it
        self.old_index
        profiling_result = RubyProf.stop
        GC.enable
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/users_cpu_profile.out.app', 'w+'))
      end
    end

    # Get users to obtain profile data
    get "/users", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end


  it 'should profile memory for feed' do
    class UsersController
      if !self.method_defined?(:old_feed)
        puts "Aliasing feed"
        alias_method :old_feed, :feed
      end

      def feed
        puts "patched feed"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::MEMORY
        RubyProf.start
        # Call the real index method to profile it
        self.old_feed
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/feed_memory_profile.out.app', 'w+'))
      end
    end

    # Get feed for user
    u = User.first
    get "/user/#{u.id}/feed"
    expect(response.status).to be 200
  end

  it 'should profile cpu for feed' do
    class UsersController
      # Alias index method if this is the first time we're monkey patching
      if !self.method_defined?(:old_feed)
        puts "Aliasing feed"
        alias_method :old_feed, :feed
      end

      def feed
        puts "patched feed"
        GC.disable
        RubyProf.measure_mode = RubyProf::CPU_TIME
        RubyProf.start
        # Call the real index method to profile it
        self.old_feed
        profiling_result = RubyProf.stop
        GC.enable
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/feed_cpu_profile.out.app', 'w+'))
      end
    end
    # Get feed for user
    u = User.first
    get "/user/#{u.id}/feed"
    expect(response.status).to be 200
  end

  it 'should profile memory for followers_posts' do
    class UsersController
      if !self.method_defined?(:old_followers_posts)
        puts "Aliasing followers_posts"
        alias_method :old_followers_posts, :followers_posts
      end

      def followers_posts
        puts "patched followers posts"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::MEMORY
        RubyProf.start
        # Call the real index method to profile it
        self.old_followers_posts
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/followers_posts_memory_profile.out.app', 'w+'))
      end
    end
    u = User.find(User.count/2)
    get "/user/#{u.id}/followers/posts", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end

  it 'should profile cpu for followers' do
    class UsersController
      if !self.method_defined?(:old_followers_posts)
        puts "Aliasing followers_posts"
        alias_method :old_followers_posts, :followers_posts
      end

      def followers_posts
        puts "patched followers_posts"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::CPU_TIME
        RubyProf.start
        # Call the real index method to profile it
        self.old_followers_posts
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/followers_posts_cpu_profile.out.app', 'w+'))
      end
    end
    u = User.find(User.count/2)
    get "/user/#{u.id}/followers/posts", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end
end
