FactoryGirl.define do
  factory :oauth_access_token, class: Doorkeeper::AccessToken do
    resource_owner_id { create(:user).id }
    application { create(:oauth_application) }
    scopes 'public'
    expires_in { 2.hours.from_now }

    trait :admin do
      application { create(:oauth_application, :owned_by_admin) }
    end

    trait :core do
      application { create(:oauth_application, :owned_by_admin) }
    end
  end
end
