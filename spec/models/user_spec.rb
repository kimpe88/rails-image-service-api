require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = FactoryGirl.build(:user)
  end

  it 'should require details all to be set on creation' do
    expect{ @user.save! }.to_not raise_error
  end

  it 'should require email to be unique' do
    @user.email = ''
    expect { @user.save! }.to raise_error
  end

  it 'should require password to be 6 characters' do
    @user.password = '12345'
    expect { @user.save! }.to raise_error
  end

  it 'should require unique usernames' do
    @user.save!
    user2 = FactoryGirl.build(:user,username: @user.username)
    expect { user2.save! }.to raise_error
  end

  it 'should require unique emails' do
    @user.save!
    user2 = FactoryGirl.build(:user,email: @user.email)
    expect { user2.save! }.to raise_error
  end

  describe 'authentication' do

    it 'should authenticate user with correct password' do
      @user.save
      expect(@user.authenticate(@user.password)).to_not be false
    end

    it 'should fail to authenticate user with incorrect password' do
      @user.save
      expect(@user.authenticate("fake_password")).to be false
    end

    it 'should return a unique token when successful' do
      @user.save
      token = User.authenticate(@user.username, @user.password)
      expect(User.where(token: token).count).to be 1
    end

    it 'should return nil when unsuccessful' do
      @user.save
      token = User.authenticate("fake_user", @user.password)
      expect(token).to be nil
      token = User.authenticate(@user.username, "fake_password")
      expect(token).to be nil
    end

    describe 'user follow functionality' do
      before :each do
        @user.save
        @users = []
        5.times do
          @users << FactoryGirl.create(:user)
        end
      end
      describe 'following' do
        it 'should successfully follow another user' do
          @user.follow(@users.first)
          @user.reload
          expect(@user.followings.first).to eq @users.first
        end

        it 'should successfully follow multiple users' do
          @users.each do |user|
            @user.follow(user)
          end
          @user.reload
          expect(@user.followings.size).to be 5
          @user.followings.each do |following|
            expect(@users.include?(following)).to be true
          end
        end
      end
      describe 'followers' do
        it 'should find followers for a user object' do
          @users.each do |user|
            user.follow(@user)
          end
          expect(@user.followers.size).to be 5
          @users.each do |user|
            expect(@user.followers.include?(user)).to be true
          end
        end
      end
    end
  end

end
