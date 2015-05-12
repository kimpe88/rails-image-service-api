require 'rails_helper'

RSpec.describe Post, type: :model do
  before :each do
    @tag = FactoryGirl.build(:tag)
    @user = FactoryGirl.build(:user)
    @post = FactoryGirl.build(:post)
  end
  it 'should correctly save posts and associations with the create post method' do
    expect(Post.create_post(@post, @tag, @user)).to be true
    post = Post.find(@post.id)
    expect(post.tags.size).to be 1
    expect(post.tagged_users.size).to be 1
    expect(post.tags.first).to eq(@tag)
    expect(post.tagged_users.first).to eq(@user)
  end

  it "should correctly save posts without associations" do
    expect(Post.create_post(@post)).to be true
    post = Post.find(@post.id)
    expect(post.tags.size).to be 0
    expect(post.tagged_users.size).to be 0
  end

  it 'should support multiple tags' do
    tags = []
    5.times do |i|
      tags << FactoryGirl.build(:tag, text: "tag#{i}")
    end
    expect(Post.create_post(@post, tags, @user)).to be true
    post = Post.find(@post.id)
    expect(post.tags.size).to be 5
    tags.each do |tag|
      expect(post.tags.include?(tag)).to be true
    end
  end

  it 'should support tagging multiple users' do
    users = []
    5.times do |i|
      users << FactoryGirl.build(:user )
    end
    expect(Post.create_post(@post, @tag, users)).to be true
    post = Post.find(@post.id)
    expect(post.tagged_users.size).to be 5
    users.each do |user|
      expect(post.tagged_users.include?(user)).to be true
    end
  end
end
