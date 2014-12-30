FactoryGirl.define do
  factory :user do
    transient do
      gender 'null'
      birth_date nil
    end
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    password { Faker::Internet.password }
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
  end
end
