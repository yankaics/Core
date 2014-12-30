FactoryGirl.define do
  factory :admin do
    sequence(:username) { |n| "#{Faker::Internet.user_name}#{n}" }
    email { Faker::Internet.safe_email("#{username}") }
    password { Faker::Internet.password }
  end
end
