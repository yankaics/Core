FactoryGirl.define do
  factory :email_pattern do
    sequence(:priority) { |n| n * 10 }
    organization
    corresponded_identity UserIdentity::IDENTITES.values.sample
    email_regexp "^(?<uid>[A-Za-z0-9]+)@example\.com$"
    uid_postparser nil
    department_code_postparser nil
    identity_detail_postparser nil
    started_at_postparser nil
  end
end
