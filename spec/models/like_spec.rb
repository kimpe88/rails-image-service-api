require 'rails_helper'

RSpec.describe Like, type: :model do
  before :each do
    @user = FactoryGirl.create(:user)
    @post = FactoryGirl.create(:post)
  end

  it 'should successfully save like' do
    expect(Like.like(@user, @post)).to_not be nil
    like = Like.last
    expect(@user.likes.first).to eq like
    expect(@post.likes.first).to eq like
  end
end
