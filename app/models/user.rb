class User < ActiveRecord::Base
  validates :username, :email, presence: true, uniqueness: true
  validates :birthdate, :description, :gender, presence: true
  validates :password, length: { minimum: 6 }

  has_many :user_tags
  has_many :posts
  has_many :tagged_posts, through: :user_tags, class_name: 'Post', source: :post

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

  #TODO Implement count following and followers when associations are done
  # Better way of doing this??
  def count_and_set_following_and_followers
    @following = 0
    @followers = 0
    {following: @following, followers: @followers}
  end
end
