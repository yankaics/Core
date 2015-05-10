FactoryGirl.define do
  factory :event_data_api, parent: :data_api do
    name 'test_events'
    table_name 'test_events'
    path 'test/events'
    description 'Event'
    notes 'Some events for testing.'
    owned_by_user true
    owner_primary_key 'id'
    owner_foreign_key 'host_id'
    schema { {
      name: { type: 'string' },
      description: { type: 'text' },
      date: { type: 'datetime' },
      host_id: { type: 'integer', index: true }
    } }

    after(:create) do |event_data_api|
      columns = event_data_api.columns
      user_ids = User.ids
      values = []

      12.times do |t|
        values[t] = [
          "#{Faker::Hacker.adjective.titlecase} Meetup",
          Faker::Hacker.say_something_smart,
          Faker::Time.between(7.days.ago, 7.days.from_now),
          user_ids.sample
        ]
      end

      event_data_api.data_model.import(columns, values, validate: false)
    end
  end

  factory :user_events_data_api, parent: :data_api do
    name 'test_user_events'
    table_name 'test_user_events'
    path 'test/attended_events'
    description 'User attended event'
    notes 'Some user\'s event participation records for testing.'
    owned_by_user true
    owner_primary_key 'id'
    owner_foreign_key 'user_id'
    schema { {
      user_id: { type: 'integer', index: true },
      event_id: { type: 'integer', index: true }
    } }

    after(:create) do |user_events_data_api|
      columns = user_events_data_api.columns
      user_ids = User.ids
      values = []

      30.times do |t|
        values[t] = [
          user_ids.sample,
          (1..15).to_a.sample
        ]
      end

      user_events_data_api.data_model.import(columns, values, validate: false)
    end
  end
end
