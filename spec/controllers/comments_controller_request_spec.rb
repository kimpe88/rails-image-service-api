require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  before :each do
    @comment = FactoryGirl.create(:comment)
    @post = FactoryGirl.create(:post)
  end

  it 'should show a comment without authentication' do
    get "/comment/#{@comment.id}"
    expect(response.status).to be 200
    response_json = JSON.parse(response.body)
    expect(response_json['success']).to be true
    expect(response_json['result']['id']).to eq @comment.id

  end

  it 'should return 404 for invalid comment id' do
    get "/comment/#{@comment.id + 10000}"
    expect(response.status).to be 404
    response_json = JSON.parse(response.body)
    expect(response_json['success']).to be false
  end

  it 'should create fail to create without authentication' do
    post '/comment/create', { comment: 'this is a comment, post: @post.id' }
    expect(response.status).to be 401
  end

  it 'should successfully create a comment with authentication' do
    post '/comment/create', { comment: 'this is a comment', post: @post.id }, authorization: @token
    expect(response.status).to be 201
    json_response = JSON.parse(response.body)
    expect(json_response['success']).to be true
  end

  it 'should set author of comment' do
    post '/comment/create', { comment: 'this is a comment', post: @post.id }, authorization: @token
    expect(response.status).to be 201
    json_response = JSON.parse(response.body)
    expect(json_response['success']).to be true
    expect(Comment.last.author).to eq @user
  end

end
