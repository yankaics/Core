require 'rails_helper'

RSpec.describe Doorkeeper::AccessToken, :type => :model do
  it { should belong_to(:resource_owner) }

  describe ".explorer_app" do
    subject(:explorer_app) { OAuthAccessToken.scopes }

    it "returns the info of scopes" do
      expect(subject).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(subject).to have_key(:public)
    end
  end
end
