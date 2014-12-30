require 'rails_helper'

RSpec.describe UserData, :type => :model do
  it_behaves_like "a user data object"
  it { should belong_to(:user) }

  describe 'instantiation' do
    let!(:user) { create(:user) }
    subject!(:user_data) { user.data }

    context "when user saved" do
      before { user.save }
      it { is_expected.to be_persisted }
    end

    context "when user destroyed" do
      before { user.destroy }
      it { is_expected.not_to be_persisted }
    end
  end
end
