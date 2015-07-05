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
      user.save!
      token
    end
  end

  # If correct accesstoken is given return user else nil
  def self.authenticate_with_token(token)
    User.find_by(token: token)
  end

  def active_model_serializer
    UserSerializer
  end

  # Follow a user only if we aren't following him/her already
  def follow(user_to_follow)
    if(self.id != user_to_follow.id && self.followings.where(id: user_to_follow.id).count == 0)
      self.followings << user_to_follow
      self.save!
    else
      false
    end
  end

end
