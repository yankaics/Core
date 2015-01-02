FactoryGirl.define do
  factory :user do
    transient do
      gender 'null'
      birth_date nil
    end
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    password { Faker::Internet.password }
    password_confirmation { password }
    name { Faker::Name.name }
    after(:create) do |user, evaluator|
      user.gender = evaluator.gender
      user.birth_date = evaluator.birth_date if evaluator.birth_date
      user.save!
    end

    trait :with_random_gender do
      gender { UserData::GENDERS.keys.sample }
    end

    trait :'16_years_old' do
      birth_date { 16.years.ago }
    end

    trait :'18_years_old' do
      birth_date { 18.years.ago }
    end

    trait :with_identity do
      transient do
        user_identity { create(:user_identity) }
      end
      after(:create) do |user, evaluator|
        user.emails.create(email: evaluator.user_identity.email)
        user.unconfirmed_emails.last.confirm!
      end
    end

    trait :in_organization do
      transient do
        organization { create(:organization) }
        identity 'staff'
      end
      after(:create) do |user, evaluator|
        user_identity = create(:user_identity, organization: evaluator.organization, identity: evaluator.identity)
        user.emails.create(email: user_identity.email)
        user.unconfirmed_emails.last.confirm!
      end
    end

    trait :in_department do
      transient do
        department { create(:department) }
        identity 'staff'
      end
      after(:create) do |user, evaluator|
        user_identity = create(:user_identity, organization: evaluator.department.organization, department: evaluator.department, identity: evaluator.identity)
        user.emails.create(email: user_identity.email)
        user.unconfirmed_emails.last.confirm!
      end
    end
  end
end
