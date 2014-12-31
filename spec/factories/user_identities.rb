FactoryGirl.define do
  factory :user_identity do
    user nil
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    organization
    identity 'staff'
    sequence(:uid) { |n| "#{Faker::Number.number(10)}#{n}" }
    department nil

    trait :with_department do
      after(:build) do |ui|
        ui.department = create(:department, organization: ui.organization) unless ui.department
      end
    end
  end
end
