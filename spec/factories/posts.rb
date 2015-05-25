FactoryGirl.define do
  factory :post do
    image "data:image/png;base64," << Base64.encode64(File.open(Rails.root + 'spec/fixtures/images/ruby.png', 'rb').read)
    # Workaround to get faker to not generate the same string over and over again
    description { Faker::Lorem.sentence }
  end

end
