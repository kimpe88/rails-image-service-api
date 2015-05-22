require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  before :each do
    @comment = FactoryGirl.create(:comment)
    @post = FactoryGirl.create(:post)
  end

  describe 'create' do
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

  describe 'update' do

    it 'should fail to update a comment without authentication' do
      patch "/comment/#{@comment.id}/update"
      expect(response.status).to be 401
    end

    it 'should successfully update a comment with comment text' do
      patch "/comment/#{@comment.id}/update", {comment: 'updated'}, authorization: @token
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      @comment.reload
      expect(@comment.comment).to eq 'updated'
    end

    it 'should should update comment tags' do
      updates = {tags: ['tag1', 'tag2']}
      patch "/comment/#{@comment.id}/update", updates, authorization: @token
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      @comment.reload
      expect(@comment.tags.size).to be 2
      updates[:tags].each do |tag_text|
        expect(@comment.tags.any? {|tag| tag.text = tag_text}).to be true
      end
    end

    it 'should update comment user_tags' do
      users = []
      updates = { user_tags: [] }
      3.times do
        users << FactoryGirl.create(:user)
        updates[:user_tags] << users.last.username
      end
      patch "/comment/#{@comment.id}/update", updates, authorization: @token
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      @comment.reload
      expect(@comment.tagged_users.size).to be 3
      users.each do |user|
        expect(@comment.tagged_users).to include user
      end
    end

    it 'should update comment with text, tags & user_tags' do
      users = []
      updates = {
        comment: 'updated',
        tags: ['tag1', 'tag2'],
        user_tags: [],
      }
      3.times do
        users << FactoryGirl.create(:user)
        updates[:user_tags] << users.last.username
      end
      patch "/comment/#{@comment.id}/update", updates, authorization: @token
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      @comment.reload
      expect(@comment.comment).to eq 'updated'
      expect(@comment.tagged_users.size).to be 3
      users.each do |user|
        expect(@comment.tagged_users).to include user
      end
      expect(@comment.tags.size).to be 2
      updates[:tags].each do |tag_text|
        expect(@comment.tags.any? {|tag| tag.text = tag_text}).to be true
      end
    end
  end


  describe 'show' do
    it 'should show comment without auth' do
      get "/comment/#{@comment.id}"
      expect(response.status).to be 200
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['result']['id']).to be @comment.id
    end

    it 'should give 404 for invalid comment' do
      get "/comment/#{@comment.id + 10000}"
      expect(response.status).to be 404
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be false
    end
  end

  describe 'post comments' do
    before :each do
      @post = FactoryGirl.create(:post)
      3.times do
        @post.comments << FactoryGirl.create(:comment)
      end
      @post.save
    end

   it 'should find comments for post without pagination arguements' do
     get "/post/#{@post.id}/comments"
     expect(response.status).to be 200
     json_response = JSON.parse(response.body)
     expect(json_response['success']).to be true
     expect(json_response['result'].size).to be 3
   end

   it 'should find comments for post with offset' do
    get "/post/#{@post.id}/comments", { offset: 1}
    expect(response.status).to be 200
    json_response = JSON.parse(response.body)
    expect(json_response['success']).to be true
    expect(json_response['result'].size).to be 2
    expect(json_response['result'].first['id']).to be @post.comments.second.id
   end

   it 'should find comments for post with limit' do
    get "/post/#{@post.id}/comments", { limit: 1}
    expect(response.status).to be 200
    json_response = JSON.parse(response.body)
    expect(json_response['success']).to be true
    expect(json_response['result'].size).to be 1
   end
  end
end
