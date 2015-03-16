FactoryGirl.define do
  factory :data_api, class: DataAPI do
    sequence(:name) { |n| "api_#{SecureRandom.urlsafe_base64(4).underscore}#{n}" }
    path { name }
    organization { nil }
    schema { { name: { type: 'string' }, text: { type: 'text' } } }
  end
end
