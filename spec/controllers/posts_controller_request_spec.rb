require 'rails_helper'
require 'base64'

RSpec.describe PostsController, type: :request do
  before :each do
    @user = FactoryGirl.create(:user)
    @tag = FactoryGirl.create(:tag)
    encoded_image = "data:image/png;base64," << Base64.encode64(File.open(Rails.root + 'spec/fixtures/images/ruby.png', 'rb').read)
    @post = {
      image: encoded_image,
      description: 'hello',
      tags: [@tag.text],
      user_tags: [@user.username]
    }
  end

  describe 'create post' do
    it 'should successfully create post with all params' do

      post '/post/create', post: @post
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response.status).to be 201
      expect(Tag.find_by(text: @tag.text)).to eq(@tag)
      expect(Post.all.size).to be 1
      expect(Post.all.first.tagged_users.first).to eq(@user)
    end

    it "should create new tags if they don't exist" do
      @post[:tags] = ["tag1", "tag2"]
      post '/post/create', post: @post
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response.status).to be 201
      expect(Tag.all.size).to be 3
    end

    it 'should ignore fake usernames' do
      @post[:user_tags] << "fake_user"
      post '/post/create', post: @post
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be true
      expect(response.status).to be 201
      expect(Post.all.first.tagged_users.size).to be 1
      expect(Post.all.first.tagged_users.first).to eq(@user)
    end

    it 'should fail without an image' do
      @post[:image] = nil
      post '/post/create', post: @post
      response_json = JSON.parse(response.body)
      expect(response_json['success']).to be false
      expect(response.status).to be 500
    end
  end

  describe 'update post' do
   it 'updates post correctly with all details' do
    pending
   end

   it 'updates post correctly without tags' do
     pending
   end

   it 'updates post correctly without user tags' do
     pending
   end
  end



end
