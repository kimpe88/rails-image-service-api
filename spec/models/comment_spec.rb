require 'rails_helper'

RSpec.describe Comment, type: :model do
  before :each do
    @users = []
    3.times do
      @users << FactoryGirl.create(:user)
    end
    @tags = []
    2.times do
      @tags << FactoryGirl.create(:tag)
    end
    @comment = FactoryGirl.create(:comment)
  end

  it 'should be have tags and user_tags' do
    expect(@comment.create_assoc_and_save(@tags, @users)).to be true
    expect(@comment.user_tags.size).to be 3
    expect(@comment.tagged_users.size).to be 3
    expect(@comment.tags.size).to be 2
  end

  it 'should have a poster' do
    @comment.author = @users.first
    expect(@comment.create_assoc_and_save).to be true
    expect(@comment.author).to eq @users.first
  end

  it 'should fail without comment text' do
    @comment.comment = ''
    expect{@comment.create_assoc_and_save}.to raise_error
  end
end
