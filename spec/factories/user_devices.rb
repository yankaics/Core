FactoryGirl.define do
  factory :user_device do
    user { create(:user) }
    type { %w(ios android).sample }
    name { Faker::Lorem.word }
    device_id nil
  end
end
