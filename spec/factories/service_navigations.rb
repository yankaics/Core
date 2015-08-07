FactoryGirl.define do
  factory :service_navigation do
    name { Faker::App.name }
    url { Faker::Internet.url }
    description { Faker::Lorem.sentence }
    color { "##{Faker::Number.hexadecimal(6)}" }
    introduction { Faker::Lorem.paragraphs.join(' ') }
    opened { [true, false].sample }
    visible { [true, false].sample }
    order { Faker::Number.between(1, 100) }
    show_on_index { [true, false].sample }
    index_order { Faker::Number.between(1, 100) }
    index_size { Faker::Number.between(1, 100) }
  end
end
