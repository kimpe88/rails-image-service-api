FactoryGirl.define do
  factory :user do
    username do
      username = ''
      begin
        username = Faker::Internet.user_name
      end until !User.find_by(username: username)
      username
    end
    email do
      email = ''
      begin
        email = Faker::Internet.email
      end until !User.find_by(email: email)
      email
    end
    password 'password'
    birthdate Faker::Date.between(60.years.ago, 15.years.ago)
    description  Faker::Lorem.paragraph
    gender { ['Male', 'Female'].sample }
  end
end
