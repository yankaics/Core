FactoryGirl.define do
  factory :notification do
    user { create(:user) }
    # application { create(:application) }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    url { Faker::Internet.url }
    # payload
    # checked_at
    # clicked_at
    # push
    # pushed_at
    # email
    # emailed_at
    # sms
    # sms_sent_at
    # fb
    # fb_sent_at
  end
end
