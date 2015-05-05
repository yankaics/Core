require "rails_helper"

describe "Sign-on Status Token (SST) requests (GET /_sst)" do
  let(:user) { create(:user) }

  context "user currently logged in" do
    it "returns the SST of current user" do
      user.confirm!
      login_as(user)
      get '/_sst'
      expect(response).to be_success
      sst_string = response.body
      sst = SignonStatusTokenService.decode(sst_string)
      expect(sst['uuid']).to eq(user.uuid)
    end
  end

  context "user not currently logged in" do
    it "returns a blank string" do
      get '/_sst'
      expect(response).to be_success
      sst_string = response.body
      expect(sst_string).to be_blank
    end
  end
end
