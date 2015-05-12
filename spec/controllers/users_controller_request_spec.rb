require 'rails_helper'

RSpec.describe UsersController, type: :request do

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
      expect(response.body).to eq(User.find(@user.id).token)
    end

    it 'should fail to login with invalid username' do
      post '/user/login', user: {username: 'wrong_user', password: @user.password}
      expect(response.status).to be 401
    end

    it 'should fail to login with wrong password' do
      post '/user/login', user: {username: @user.username, password: 'wrong_password'}
      expect(response.status).to be 401
    end
  end

  describe 'user information' do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    it 'should return status 404 when getting a user id that does not exist' do
      get '/user/1'
      expect(response.status).to be 404
    end

    it 'it should return details of user with valid id' do
      #TODO There should be a better way to do this
      get "/user/#{@user.id}"
      expect(response.status).to be 200
      expect(JSON.parse(response.body)["id"]).to be @user.id
    end
  end

end
