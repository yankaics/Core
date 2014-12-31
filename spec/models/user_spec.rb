require 'rails_helper'

RSpec.describe User, :type => :model do
  its(:devise_modules) { should include(:database_authenticatable, :timeoutable, :registerable, :confirmable, :lockable, :recoverable, :rememberable, :trackable, :validatable) }
  it_behaves_like "a user data object"

  it { should have_one(:data) }
  it { should have_many(:identities) }
  it { should have_many(:organizations) }
  it { should have_many(:departments) }

  it { should respond_to(:organization, :organization_code, :department, :department_code) }

  it { should validate_presence_of(:name) }

  context "with emails" do
    subject { create(:user) }
    before do
      @conf_email_1 = subject.emails.create!(email: Faker::Internet.email)
      @conf_email_2 = subject.emails.create!(email: Faker::Internet.email)
      @unconf_email_1 = subject.emails.create!(email: Faker::Internet.email)
      @unconf_email_2 = subject.emails.create!(email: Faker::Internet.email)
      @conf_email_1.confirm!
      @conf_email_2.confirm
      subject.clear_association_cache
    end
    its(:emails) { is_expected.to contain_exactly(@conf_email_1, @conf_email_2) }
    its(:unconfirmed_emails) { is_expected.to contain_exactly(@unconf_email_1, @unconf_email_2) }
  end

  context "a not-owned primary_identity is being assigned" do
    subject(:user) { create(:user) }
    before do
      other_user = create(:user, :with_identity)
      user.primary_identity = other_user.primary_identity
      user.save
    end
    its(:primary_identity) { is_expected.to be_nil }
  end

  context "with user_identities but primary_identity isn't assigned" do
    subject(:user) { create(:user) }
    before do
      email = Faker::Internet.safe_email
      create(:user_identity, :with_department, email: email)
      user.emails.create(email: email).confirm
      user.primary_identity = nil
      user.save
    end
    its(:primary_identity) { is_expected.not_to be_nil }
  end

  context "has multiple user_identities and the primary_identity's email is destroyed" do
    subject(:user) { create(:user) }
    before do
      3.times do
        create(:user_identity, :with_department, user_id: user.id)
      end
    end
    it "sets the first remaining identity as primary_identity automatically" do
      user
    end
  end

  describe "instantiation" do
    subject(:user) { create(:user) }

    context "when created" do
      it { is_expected.not_to be_confirmed }
      its(:data) { is_expected.to be_an(Object) }
      its(:gender) { is_expected.to eq('null') }
    end

    context "after confirmed" do
      before { user.confirm! }
      it { is_expected.to be_confirmed }
    end
  end
end
