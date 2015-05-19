class User < ActiveRecord::Base
  validates :username, :email, presence: true, uniqueness: true
  validates :birthdate, :description, :gender, presence: true
  validates :password, length: { minimum: 7 }

  has_many :user_tags
  has_many :posts
  has_many :tagged_posts, through: :user_tags, class_name: 'Post', source: :post
  has_many :followings, class_name: 'Following', foreign_key: 'follower'

  attr_accessor :following, :followers

  #TODO implement encrypted passwords
  def self.hash_password(password)
    password
  end

  # Check username and password, if they match
  # generate a globally unique token and return it
  def self.authenticate(username, password)
    user = self.find_by(username: username)
    if user && user.password == self.hash_password(password)
      begin
        token = SecureRandom.hex
      end while self.find_by(token: token)
      user.token = token
      user.save!
      token
    end
  end

  def self.followers(user, offset = 0, limit = 10)
    #TODO more ruby way of doing this?
    User.find_by_sql([ "SELECT users.* FROM users, followings WHERE followings.follower = users.id AND followings.followee = ?" +
                       " ORDER BY id LIMIT ?,?", user, offset, limit])
  end

  def follow(user)
    self.followings << Following.new(followee: user)
    self.save
  end

  def as_json(options = {})
    count_and_set_following_and_followers
    super({except: [:password, :token], include: :posts, methods: [:following, :followers]}.merge!(options))
  end

  private
  #TODO Implement count following and followers when associations are done
  # Better way of doing this??
  def count_and_set_following_and_followers
    @following = 0
    @followers = 0
    {following: @following, followers: @followers}
  end
end
