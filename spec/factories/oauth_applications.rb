FactoryGirl.define do
  factory :oauth_application, class: Doorkeeper::Application do
    owner { create(:user) }
    name { Faker::App.name }
    description { Faker::Lorem.sentence }
    app_url { Faker::Internet.url }
    redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

    trait :owned_by_admin do
      owner { create(:admin) }
    end
  end
end
