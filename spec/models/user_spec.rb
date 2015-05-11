require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = FactoryGirl.build(:user)
  end
  it 'should required details all to be set on creation' do
    expect{ @user.save! }.to_not raise_error
  end

  it 'should require email to be unique' do
    @user.email = ''
    expect { @user.save! }.to raise_error
  end

  it 'should require password to be 6 characters' do
    @user.password = '12345'
    expect { @user.save! }.to raise_error
  end

  it 'should require date to be a valid date format' do
    @user.birthdate= Faker::Date.forward(30)
    expect { @user.save! }.to raise_error
  end

end
