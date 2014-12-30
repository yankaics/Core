require 'rails_helper'

RSpec.describe User, :type => :model do
  its(:devise_modules) { should include(:database_authenticatable, :timeoutable, :registerable, :confirmable, :lockable, :recoverable, :rememberable, :trackable, :validatable) }
  it_behaves_like "a user data object"

  it { should have_one(:data) }

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
