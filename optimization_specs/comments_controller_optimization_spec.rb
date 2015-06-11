require 'rails_helper'
require 'assert_performance'

RSpec.describe CommentsController, type: :request do
  before :each do
    @post = Post.find(Post.count/2)
  end
  it 'should profile memory for post_comments' do
    class CommentsController
      # Alias index method if this is the first time we're monkey patching
      if !self.method_defined?(:old_post_comments)
        puts "Aliasing post_commens"
        alias_method :old_post_comments, :post_comments
      end

      def post_comments
        puts "patched post_comments"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::MEMORY
        RubyProf.start
        # Call the real index method to profile it
        self.old_post_comments
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/post_comments_memory_profile.out.app', 'w+'))
      end
    end

    get "/post/#{@post.id}/comments", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end

  it 'should profile memory for post_comments' do
    class CommentsController
      # Alias index method if this is the first time we're monkey patching
      if !self.method_defined?(:old_post_comments)
        puts "Aliasing post_commens"
        alias_method :old_post_comments, :post_comments
      end

      def post_comments
        puts "patched post_comments"
        GC.enable_stats
        RubyProf.measure_mode = RubyProf::CPU_TIME
        RubyProf.start
        # Call the real index method to profile it
        self.old_post_comments
        profiling_result = RubyProf.stop
        printer = RubyProf::CallTreePrinter.new(profiling_result)
        printer.print(File.open(Rails.root + 'benchmark/post_comments_cpu_profile.out.app', 'w+'))
      end
    end

    get "/post/#{@post.id}/comments", {offset: 0}, authorization: @token
    expect(response.status).to be 200
  end
end
