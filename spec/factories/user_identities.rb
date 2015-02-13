FactoryGirl.define do
  factory :user_identity do
    user nil
    name { Faker::Name.name }
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    organization
    identity 'staff'
    sequence(:uid) { |n| "#{Faker::Number.number(10)}#{n}" }
    department nil

    permit_changing_department_in_group false
    permit_changing_department_in_organization false

    trait :with_department do
      after(:build) do |ui|
        ui.department = create(:department, organization: ui.organization) unless ui.department
      end
    end
  end
end
