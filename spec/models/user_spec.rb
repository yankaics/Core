require 'rails_helper'

RSpec.describe User, :type => :model do
  its(:devise_modules) { should include(:database_authenticatable, :timeoutable, :registerable, :confirmable, :lockable, :recoverable, :rememberable, :trackable, :validatable) }
  it_behaves_like "a user data object"

  it { should have_one(:data) }

  it { should validate_presence_of(:name) }

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
