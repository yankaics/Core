FactoryGirl.define do
  factory :data_api, class: DataAPI do
    name { SecureRandom.hex }
    path { SecureRandom.hex }
    organization { nil }
    schema { { id: {}, name: {} } }
  end
end
