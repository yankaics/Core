require 'rails_helper'

RSpec.describe Doorkeeper::Application, :type => :model do
  it { should belong_to(:owner) }
  it { should validate_presence_of(:owner) }

  context "created as an user application" do
    subject { create(:oauth_application) }

    it { is_expected.not_to be_core_app }
    its(:rth_refreshed_at) { is_expected.to eq DateTime.now.change(min: 0, sec: 0) }
    its(:core_rth_refreshed_at) { is_expected.to eq DateTime.now.change(min: 0, sec: 0) }
    its(:rtd_refreshed_at) { is_expected.to eq Date.today }
    its(:core_rtd_refreshed_at) { is_expected.to eq Date.today }
  end

  context "created as an core application" do
    subject { create(:oauth_application, :owned_by_admin) }

    it { is_expected.to be_core_app }
  end
end
