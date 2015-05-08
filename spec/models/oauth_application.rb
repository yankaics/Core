require 'rails_helper'

RSpec.describe Doorkeeper::Application, :type => :model do
  it { should belong_to(:owner) }
  it { should validate_presence_of(:owner) }

  describe ".explorer_app" do
    subject(:explorer_app) { OAuthApplication.explorer_app }
    it "returns the API Explorer app" do
      expect(subject.uid).to eq('api_docs_api_explorer')
      expect(subject.owner.username).to eq('api_docs_api_explorer_owner')
      expect(subject.owner_type).to eq('User')
    end
  end

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

  describe "#regenerate_secret!" do
    subject(:app) { create(:oauth_application) }
    it "regenerates the application secret" do
      expect do
        app.regenerate_secret!
      end.to change { app.secret }
      new_secret = app.secret
      app.reload
      expect(app.secret).to eq new_secret
    end
  end
end
