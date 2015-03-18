FactoryGirl.define do
  factory :data_api, class: DataAPI do
    sequence(:name) { |n| "api_#{SecureRandom.urlsafe_base64(4).underscore}#{n}" }
    path { name }
    organization { nil }
    schema { { name: { type: 'string' }, text: { type: 'text' } } }

    trait :with_data do
      transient do
        data_count 10
      end

      after(:create) do |data_api, evaluator|
        columns = data_api.columns
        values = []

        evaluator.data_count.times do |t|
          values[t] = []

          data_api.schema.each_pair do |name, column|
            case column[:type]
            when 'string'
              values[t] << "#{Faker::Hacker.noun}#{t}"
            when 'integer'
              values[t] << rand(1000) + t * 10_000
            when 'float'
              values[t] << rand + t
            when 'boolean'
              values[t] << [true, false].sample
            when 'text'
              values[t] << "#{Faker::Hacker.say_something_smart} (#{t})"
            when 'datetime'
              values[t] << Faker::Date.between(10.days.ago, 10.days.from_now) + t
            end
          end
        end

        data_api.data_model.import(columns, values, validate: false)
      end
    end
  end
end
