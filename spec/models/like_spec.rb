require 'rails_helper'

RSpec.describe Like, type: :model do
  before :each do
    @user = FactoryGirl.create(:user)
    @post = FactoryGirl.create(:post)
  end

  it 'should successfully save like' do
    expect(Like.like(@user, @post)).to_not be false
    like = Like.last
    expect(@user.likes.first).to eq like
    expect(@post.likes.first).to eq like
  end

  it 'should not be able to like the same post twice' do
    expect(Like.like(@user, @post)).to_not be false
    expect(Like.like(@user, @post)).to be false
    like = Like.last
    expect(@user.likes.first).to eq like
    expect(@post.likes.first).to eq like
    expect(Like.count).to be 1
  end
end
