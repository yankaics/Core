FactoryGirl.define do
  factory :user do
    transient do
      gender 'unspecified'
      birth_date nil
    end

    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    password { Faker::Internet.password }
    password_confirmation { password }
    username { Faker::Internet.user_name }
    name { Faker::Name.name }
    mobile nil

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

    trait :confirmed do
      after(:create) do |user|
        user.confirm!
      end
    end

    trait :with_identity do
      transient do
        user_identity { create(:user_identity) }
      end
      after(:create) do |user, evaluator|
        user.confirm!
        user.emails.create(email: evaluator.user_identity.email)
        user.unconfirmed_emails.last.confirm!
        user.reload
      end
    end

    trait :in_organization do
      transient do
        organization { create(:organization) }
        identity 'staff'
      end
      after(:create) do |user, evaluator|
        user.confirm!
        user_identity = create(:user_identity, organization: evaluator.organization, identity: evaluator.identity)
        user.emails.create(email: user_identity.email)
        user.unconfirmed_emails.last.confirm!
        user.reload
      end
    end

    trait :in_department do
      transient do
        department { create(:department) }
        identity 'staff'
      end
      after(:create) do |user, evaluator|
        user.confirm!
        user_identity = create(:user_identity, organization: evaluator.department.organization, department: evaluator.department, identity: evaluator.identity)
        user.emails.create(email: user_identity.email)
        user.unconfirmed_emails.last.confirm!
        user.reload
      end
    end
  end

  factory :user_email do
    user
    email { Faker::Internet.safe_email }

    factory :user_identity_link do
      transient do
        user_identity { create(:user_identity) }
      end
      email { user_identity.email }
      after(:create) do |user_email, evaluator|
        user_email.confirm!
      end

      trait :in_organization do
        transient do
          organization { create(:organization) }
          identity 'staff'
          user_identity { create(:user_identity, organization: organization, identity: identity) }
        end
      end
    end
  end
end
