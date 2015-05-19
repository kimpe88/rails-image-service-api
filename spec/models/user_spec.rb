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

    describe 'following' do
      before :each do
        @user.save
        @users = []
        5.times do
          @users << FactoryGirl.create(:user)
        end
      end
      it 'should successfully follower another user' do
        @user.follow(@users.first)
        @user.reload
        expect(@user.followings.first.followee).to eq @users.first
      end

      it 'should successfully follow multiple users' do
        @users.each do |user|
          @user.follow(user)
        end
        @user.reload
        expect(@user.followings.size).to be 5
        @user.followings.each do |following|
          expect(@users.include?(following.followee)).to be true
        end
      end
    end
  end
end
