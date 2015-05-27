namespace :benchmark do
  desc "TODO"
  task profiler: :environment do
    ids = setup
    test do
      threads count: 100, rampup: 10, continue_forever: true do
        header({name: 'Authorization', value: "Token #{ids[:user].token}"})
        visit name: 'User listing', url: "http://localhost:3000/users"
        visit name: 'User feed', url: "http://localhost:3000/user/#{ids[:user].id}/feed"
        visit name: 'Followers count', url: "http://localhost:3000/user/#{ids[:user].id}/followers"
        visit name: 'Followers post', url: "http://localhost:3000/user/#{ids[:user].id}/followers/posts"
        visit name: 'Post comments', url: "http://localhost:3000/user/#{ids[:post].id}/followers/posts"
      end
    end.jmx(file: "benchmark/profiler_testplan.jmx")
  end

  private
  def setup
    User.connection
    Post.connection
    ids = {}
    ids[:user] = User.all.sample
    ids[:post] = Post.all.sample
    User.authenticate(ids[:user].username, "password")
    ids[:user].reload
    return ids
  end
end
