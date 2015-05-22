class User < ActiveRecord::Base
  has_secure_password
  validates :username, :email, presence: true, uniqueness: true
  validates :birthdate, :description, :gender, presence: true
  validates :password, length: { minimum: 6 }, on: :create

  has_many :user_tags
  has_many :posts, foreign_key: 'author_id'
  has_many :likes
  has_many :tagged_posts, through: :user_tags, class_name: 'Post', source: :post

  has_many :user_followings
  has_many :followings, through: :user_followings

  has_many :inverse_user_followings, class_name: 'UserFollowing', foreign_key: 'following_id'
  has_many :followers, through: :inverse_user_followings, source: :user

  # Check username and password, if they match
  # generate a globally unique token and return it
  def self.authenticate(username, password)
    user = self.find_by(username: username)
    if user && user.authenticate(password)
      begin
        token = SecureRandom.hex
      end while self.find_by(token: token)
      user.token = token
      # TODO should this be without !?
      user.save!
      token
    end
  end

  # If correct accesstoken is given return user else nil
  def self.authenticate_with_token(token)
    User.find_by(token: token)
  end

  def following_count
    self.followings.count
  end

  def followers_count
    self.followers.count
  end

  def follow(user_to_follow)
    self.followings << user_to_follow
    self.save!
  end

  def as_json(options = {})
    super({except: [:password, :token], include: :posts, methods: [:following_count, :followers_count]}.merge!(options))
  end

end
