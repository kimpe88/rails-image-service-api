require 'rails_helper'

RSpec.describe UsersController, type: :request do

  describe 'user following' do
    it 'should show users followed by that user' do
      pending("implement following first")
    end

    it 'should fail with invalid id' do
      pending("implement following first")
    end
  end

  describe 'user signup' do
    before :each do
      @user = FactoryGirl.build(:user)
      @hash = {}
      @user.attributes.each { |k,v| @hash[k.to_sym] = v  unless v.nil? }
    end

    it 'should signup successfully with the correct details' do
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
    before :each do
      @user = FactoryGirl.create(:user)
    end
    it 'should login sucessfully with correct details' do
      post '/user/login', user: {username: @user.username, password: @user.password}
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['result']).to eq(User.find(@user.id).token)
    end

    it 'should fail to login with invalid username' do
      post '/user/login', user: {username: 'wrong_user', password: @user.password}
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(response.status).to be 401
    end

    it 'should fail to login with wrong password' do
      post '/user/login', user: {username: @user.username, password: 'wrong_password'}
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(response.status).to be 401
    end
  end

  describe 'user information' do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    it 'should return status 404 when getting a user id that does not exist' do
      begin
        id = rand(1..1000)
      end until id != @user.id
      get "/user/#{id}"
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
      expect(response.status).to be 404
    end

    it 'it should return details of user with valid id' do
      #TODO There should be a better way to do this
      get "/user/#{@user.id}"
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
        get '/users', {offset: 0}
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 10
        expect(json_response['result'].length).to be 5
      end

      it 'should limit responses correctly' do
        get '/users', {offset: 0, limit: 2}
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 2
        expect(json_response['result'].length).to be 2
      end

      it 'should give correct results with offset' do
        get '/users', {offset: 2}
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 2
        expect(json_response['limit']).to be 10
        expect(json_response['result'].length).to be 3
      end

      it 'should limit to 100 when using too large limit' do
        get '/users', {offset: 0, limit: 1000}
        json_response =  JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['offset']).to be 0
        expect(json_response['limit']).to be 100
        expect(json_response['result'].length).to be 5
      end
    end
  end
end
