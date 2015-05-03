FactoryGirl.define do
  factory :admin do
    sequence(:username) { |n| "#{Faker::Internet.user_name}#{n}" }
    email { Faker::Internet.safe_email("#{username}") }
    password { Faker::Internet.password }
    password_confirmation { password }
    scoped_organization_code nil

    trait :scoped do
      scoped_organization_code { create(:organization).code }
    end
  end
end
