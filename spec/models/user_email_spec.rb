require 'rails_helper'
require 'validates_email_format_of/rspec_matcher'

RSpec.describe UserEmail, :type => :model do
  let(:user) { create(:user) }
  let(:user_email) { user.emails.create(email: Faker::Internet.safe_email) }

  it { should belong_to(:user) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:email) }

  it "validates email format" do
    user_email.email = 'the_quick_brown-fox*jumps^over-the_lazy_dog'
    expect(user_email).not_to be_valid
    expect(user).not_to be_valid
  end

  context "when created" do
    subject { user_email }
    it { is_expected.not_to be_confirmed }
  end

  context "when confirmed" do
    subject { user_email.confirm! }
    it { is_expected.to be_confirmed }
  end
end
