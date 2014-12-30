FactoryGirl.define do
  factory :department do
    organization
    parent nil
    sequence(:name) { |n| "#{Faker::Company.name} #{n} Department" }
    short_name { name.gsub(/[^A-Z0-9]/, '') }
    sequence(:code) { |n| "#{Faker::Address.building_number}#{n}" }
  end
end
