FactoryGirl.define do
  factory :oauth_access_token, class: Doorkeeper::AccessToken do
    resource_owner_id { create(:user).id }
    application { create(:oauth_application) }
    scopes 'public'
    expires_in { 2.hours.from_now }
  end
end
