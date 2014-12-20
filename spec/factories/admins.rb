FactoryGirl.define do
  factory :admin do

    sequence(:username) do |n|
      "admin#{n}"
    end

    sequence(:email) do |n|
      "foo#{n}@bar.com"
    end

    password "password"
  end

end
