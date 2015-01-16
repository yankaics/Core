require 'rails_helper'
require 'validates_email_format_of/rspec_matcher'

RSpec.describe UserEmail, :type => :model do
  let(:user) { create(:user) }
  let(:user_email) { user.emails.create(email: Faker::Internet.safe_email) }

  it { should belong_to(:user) }
  it { should have_one(:associated_user_identity) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:email) }
  # it { should validate_uniqueness_of(:confirmation_token).allow_nil }

  it "validates email format" do
    user_email.email = 'the_quick_brown-fox*jumps^over-the_lazy_dog'
    expect(user_email).not_to be_valid
    expect(user).not_to be_valid
  end

  context "when created" do
    subject { user_email }
    it { is_expected.not_to be_confirmed }
  end

  context "when a same and confirmed email exists" do
    before do
      @email = Faker::Internet.safe_email
      create(:user).emails.create(email: @email).confirm!
    end
    subject { user.emails.create(email: @email) }

    it { is_expected.not_to be_valid }

    it "can't be confirmed" do
      expect { subject.confirm! }.to raise_error
      expect(subject.confirm).to be false
      expect(subject.confirmed?).to be false
    end
  end

  context "when a same and unconfirmed email exists" do
    before do
      @email = Faker::Internet.safe_email
      create(:user).emails.create(email: @email)
    end
    subject { user.emails.create(email: @email) }

    it { is_expected.to be_valid }

    it "can be confirmed" do
      expect(subject.confirm).not_to be false
      expect(subject.confirmed?).to be true
    end
  end

  context "when confirmed" do
    subject { user_email.confirm! }
    it { is_expected.to be_confirmed }

    context "having matched EmailPattern" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_email) { user.emails.create(email: 'B10132023@mail.ntust.edu.tw') }

      it "creates UserIdentity for the user" do
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
      end
    end

    context "having matched predefined UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_identity) { create(:user_identity, organization: ntust, email: 'me@ntust.edu.tw') }
      let!(:user_email) { user.emails.create(email: 'me@ntust.edu.tw') }

      it "links the UserIdentity to the user" do
        expect(user.organization).to eq nil
        user_email.confirm
        user.reload
        expect(user.organization).to eq ntust
      end
    end
  end

  context "when destroyed" do
    context "with corresponding generated UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_email) { user.emails.create(email: 'B10132023@mail.ntust.edu.tw') }
      before { user_email.confirm }

      it "destroys the UserIdentity for the user" do
        user_identity = user.identities.first
        user_email.destroy
        user.reload
        expect(user.identities.count).to eq(0)
        expect(UserIdentity.exists?(user_identity)).to be false
      end
    end

    context "with corresponding predefined UserIdentity" do
      let!(:ntust) { create(:ntust_organization) }
      let!(:user_identity) { create(:user_identity, organization: ntust, email: 'me@ntust.edu.tw') }
      let!(:user_email) { user.emails.create(email: 'me@ntust.edu.tw') }
      before { user_email.confirm }

      it "unlinks the UserIdentity with the user" do
        user_identity = user.identities.first
        user_email.destroy
        user.reload
        expect(user.identities.count).to eq(0)
        expect(UserIdentity.exists?(user_identity)).to be true
      end
    end
  end
end
