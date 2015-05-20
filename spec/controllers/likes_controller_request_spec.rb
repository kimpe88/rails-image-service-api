require 'rails_helper'

RSpec.describe LikesController, type: :request do
  before :each do
    @post = FactoryGirl.create(:post)
  end
  it 'should successfully like for a user and post' do
    post "/post/#{@post.id}/like", nil, authorization: @token
    json_response = JSON.parse(response.body)
    expect(response.status).to be 201
    expect(json_response['success']).to be true
  end

  it 'should fail to like when the user is not logged in' do
    post "/post/#{@post.id}/like", nil, authorization: ActionController::HttpAuthentication::Token.encode_credentials("fake_token")
    expect(response.status).to be 401
  end

  it 'should fail to fail to like a nonexisting post' do
    post "/post/#{@post.id + 10000}/like", nil, authorization: @token
    json_response = JSON.parse(response.body)
    expect(response.status).to be 400
    expect(json_response['success']).to be false
  end

  it 'should list likes for a post even if not logged in' do
    users = []
    2.times do
      users << FactoryGirl.create(:user)
      Like.like(users.last, @post)
    end
    get "/post/#{@post.id}/likes"
    expect(response.status).to be 200
    json_response = JSON.parse(response.body)
    expect(json_response['result'].size).to be 2
    users.each do |user|
      expect(json_response['result'].any? { |like| like['user_id'] == user.id}).to be true
    end

  end


end
