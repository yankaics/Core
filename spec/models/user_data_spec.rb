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

    context "when updated" do
      before do
        Timecop.travel(10.years.from_now)
        user_data.birth_date = 30.years.ago
        user_data.save
      end
      it "updates the user's update time" do
        user.reload
        expect(user.updated_at.to_date).to eq(user_data.updated_at.to_date)
      end
    end
  end
end
