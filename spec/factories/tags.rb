FactoryGirl.define do
  factory :tag do
    text do
      begin
        word =  Faker::Lorem.word
      end until !Tag.find_by(text: word)
    word
    end
  end
end
