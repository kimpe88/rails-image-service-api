FactoryGirl.define do
  factory :post do
    image "data:image/png;base64," << Base64.encode64(File.open(Rails.root + 'spec/fixtures/images/ruby.png', 'rb').read)
    description Faker::Lorem.sentence
  end

end
