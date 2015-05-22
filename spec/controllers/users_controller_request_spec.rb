require 'rails_helper'

RSpec.describe UsersController, type: :request do
  describe 'feed' do
    before :each do
      @user.posts << FactoryGirl.create(:post)
      5.times do
        user = FactoryGirl.create(:user)
        @user.followings << user
        2.times do
          user.posts << FactoryGirl.create(:post)
          sleep 0.1
        end
      end
      # These should not end up in feed since the user
      # is not following them
      3.times do
        u = FactoryGirl.create(:user)
        u.posts << FactoryGirl.create(:post)
      end
      @user.save!
    end

    it 'should get feed for provided user' do
      get "/user/#{@user.id}/feed", { limit: 15 }
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].size).to be 11
    end

    it 'should sort results after time' do
      user = FactoryGirl.create(:user)
      @user.followings << user
      sleep 1
      user.posts << FactoryGirl.create(:post)
      @user.save!
      get "/user/#{@user.id}/feed", { limit: 15 }
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].size).to be 12
      expect(response_json['result'].first['id']).to eq user.posts.last.id
    end

    it 'it should not include followings followings posts' do
      user = FactoryGirl.create(:user)
      user.posts << FactoryGirl.create(:post)
      user.save!
      @user.followings.each do |following_user|
        following_user.followings << user
        following_user.save!
    end

    get "/user/#{@user.id}/feed"
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].any? {|p| p['id'] == user.posts.last.id}).to be false
    end

    it 'should return results with offset' do
      get "/user/#{@user.id}/feed", { offset: 1 }
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['offset']).to be 1
      expect(response_json['limit']).to be 10
      expect(response_json['result'].size).to be 10
    end

    it 'should return as many results as limit' do
      get "/user/#{@user.id}/feed", { limit: 3 }
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].size).to be 3
      expect(response_json['offset']).to be 0
      expect(response_json['limit']).to be 3
    end
  end
  describe 'auth' do
    it 'should return 401 with wrong token' do
      get "/users", {offset: 0}, authorization: ActionController::HttpAuthentication::Token.encode_credentials("fake_token")
      expect(response.status).to be 401
    end

    it 'should be successful with correct token' do
      get "/users", {offset: 0}, authorization: @token
      expect(response.status).to be 200
    end
  end
  describe 'user information' do
    it 'should show number of followings correctly' do
      3.times do
        user = FactoryGirl.create(:user)
        @user.follow(user)
      end
      get "/user/#{@user.id}", nil, authorization: @token
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['result']['following_count']).to be 3
      expect(json_response['result']['followers_count']).to be 0
    end

    it 'should show number of followers correctly' do
      4.times do
        user = FactoryGirl.create(:user)
        user.follow(@user)
      end
      get "/user/#{@user.id}", nil, authorization: @token
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['result']['followers_count']).to be 4
      expect(json_response['result']['following_count']).to be 0
    end

    it 'should return status 404 when getting a user id that does not exist' do
      begin
        id = rand(1..1000)
      end until id != @user.id
      get "/user/#{id}", nil, authorization: @token
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(response.status).to be 404
    end

    it 'it should return details of user with valid id' do
      #TODO There should be a better way to do this
      get "/user/#{@user.id}", nil, authorization: @token
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['result']["id"]).to be @user.id
    end

    describe 'multiple users' do
      before :each do
        @users = [@user]
        4.times do
          @users << FactoryGirl.create(:user)
        end
      end

      it 'should find all users with offset no and no limit' do
        get '/users', {offset: 0}, authorization: @token
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 10
        expect(json_response['result'].length).to be 5
      end

      it 'should limit responses correctly' do
        get '/users', {offset: 0, limit: 2}, authorization: @token
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 2
        expect(json_response['result'].length).to be 2
      end

      it 'should give correct results with offset' do
        get '/users', {offset: 2}, authorization: @token
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 2
        expect(json_response['limit']).to be 10
        expect(json_response['result'].length).to be 3
      end

      it 'should limit to 100 when using too large limit' do
        get '/users', {offset: 0, limit: 1000}, authorization: @token
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 100
        expect(json_response['result'].length).to be 5
      end
    end
  end
  describe 'following' do
    it 'should find an empty array if the user does not follow anyone' do
      get "/user/#{@user.id}/following", {offset: 0}, authorization: @token
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result']).to eq []
    end

    it 'should find details of a user that is followed' do
      user = FactoryGirl.create(:user)
      @user.follow(user)
      get "/user/#{@user.id}/following", {offset: 0}, authorization: @token
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].first['id']).to eq user.id
    end

    it 'should find ids of all users a specific user is following' do
      users = []
      5.times do
        users << FactoryGirl.create(:user)
        @user.follow(users.last)
      end
      get "/user/#{@user.id}/following", {offset: 0}, authorization: @token
      expect(response.status).to be 200
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response_json['result'].size).to be 5
    end

    it 'should give empty results with nonexisting user' do
      get "/user/1111/following", {offset: 0}, authorization: @token
      expect(response.status).to be 404
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be false
    end

    describe 'pagination' do
      before :each do
        @users = []
        5.times do
          @users << FactoryGirl.create(:user)
          @user.follow(@users.last)
        end
      end
      it 'should return following results with offset' do
        get "/user/#{@user.id}/following", {offset: 0}, authorization: @token
        expect(response.status).to be 200
        no_offset_json = JSON.parse(response.body)
        expect(no_offset_json['success']).to be true
        expect(no_offset_json['result'].size).to be 5

        get "/user/#{@user.id}/following", {offset: 1}, authorization: @token
        expect(response.status).to be 200
        offset_json = JSON.parse(response.body)
        expect(offset_json['success']).to be true
        expect(offset_json['result'].size).to be 4
        expect(no_offset_json['result'].second).to eq offset_json['result'].first
      end

      it 'should limit following correctly if value is supplied' do
        get "/user/#{@user.id}/following", {offset: 0, limit: 3}, authorization: @token
        expect(response.status).to be 200
        no_offset_json = JSON.parse(response.body)
        expect(no_offset_json['success']).to be true
        expect(no_offset_json['result'].size).to be 3
      end
    end
  end

  describe 'followers' do
    before :each do
      @users = []
      5.times do
        @users << FactoryGirl.create(:user)
        @users.last.follow(@user)
      end
    end
    it 'should return followers results with offset' do
      get "/user/#{@user.id}/followers", {offset: 0}, authorization: @token
      expect(response.status).to be 200
      no_offset_json = JSON.parse(response.body)
      expect(no_offset_json['success']).to be true
      expect(no_offset_json['result'].size).to be 5

      get "/user/#{@user.id}/followers", {offset: 1}, authorization: @token
      expect(response.status).to be 200
      offset_json = JSON.parse(response.body)
      expect(offset_json['success']).to be true
      expect(offset_json['result'].size).to be 4
      expect(no_offset_json['result'].second).to eq offset_json['result'].first
    end

    it 'should limit follwers correctly if value is supplied' do
      get "/user/#{@user.id}/followers", {offset: 0, limit: 3}, authorization: @token
      expect(response.status).to be 200
      no_offset_json = JSON.parse(response.body)
      expect(no_offset_json['success']).to be true
      expect(no_offset_json['result'].size).to be 3
    end
  end

  describe 'user signup' do
    before :each do
      @user = FactoryGirl.build(:user)
      @hash = {}
      @user.attributes.each { |k,v| @hash[k.to_sym] = v  unless v.nil? }
    end

    it 'should signup successfully with the correct details' do
      @hash[:password] = 'password'
      post '/user/signup', user: @hash
      expect(response.status).to eq(201)
    end

    it 'should fail with missing information' do
      @hash.keys.each do |key|
        post '/user/signup', user: @hash.except(key)
        expect(response.status).to eq(500)
      end
    end

    it 'should fail with taken username' do
      @user.save!
      user2 = FactoryGirl.build(:user, username: @user[:username])
      hash2 = {}
      user2.attributes.each { |k,v| hash2[k.to_sym] = v  unless v.nil? }
      post '/user/signup', user: hash2
      expect(response.status).to eq(500)
    end

    it 'should fail with taken email' do
      @user.save!
      user2 = FactoryGirl.build(:user, email: @user[:email])
      hash2 = {}
      user2.attributes.each { |k,v| hash2[k.to_sym] = v  unless v.nil? }
      post '/user/signup', user: hash2
      expect(response.status).to eq(500)
    end

    it 'should fail with insufficient password' do
      @hash[:password] = '12345'
      post '/user/signup', user: @hash
      expect(response.status).to eq(500)
    end
  end

  describe 'user login' do
    #it 'should login sucessfully with correct details' do
      #post '/user/login', user: {username: @user.username, password: @user.password}
      #expect(response.status).to be 200
      #json_response = JSON.parse(response.body)
      #expect(json_response['success']).to be true
      #expect(json_response['result']).to eq(User.find(@user.id).token)
    #end

    #it 'should fail to login with invalid username' do
      #post '/user/login', user: {username: 'wrong_user', password: @user.password}
      #json_response = JSON.parse(response.body)
      #expect(json_response['success']).to be false
      #expect(response.status).to be 401
    #end

    #it 'should fail to login with wrong password' do
      #post '/user/login', user: {username: @user.username, password: 'wrong_password'}
      #json_response = JSON.parse(response.body)
      #expect(json_response['success']).to be false
      #expect(response.status).to be 401
    #end
  end


end
