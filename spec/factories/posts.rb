FactoryGirl.define do
  factory :post do
    image Faker::Avatar.image
    description Faker::Lorem.sentence
  end

end
