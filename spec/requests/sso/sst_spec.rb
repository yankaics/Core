require "rails_helper"

describe "Sign-on Status Token (SST) requests" do
  let(:user) { create(:user) }

  describe "GET /_sst" do
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

  describe "GET /refresh_sst" do
    context "user currently signed in" do
      before do
        user.confirm!
        login_as(user)
      end

      it "sets the sign-on status token (sst) in cookie" do
        get '/refresh_sst'
        sst_string = response.cookies['_sst']
        sst = SignonStatusTokenService.decode(sst_string)
        expect(sst['id']).to eq(user.id)
        expect(sst['uuid']).to eq(user.uuid)
      end
    end

    context "user not currently signed in" do
      before do
        user = create(:user)
        user.confirm!
        login_as(user)
        get '/refresh_sst'
        expect(response.cookies).to have_key '_sst'
        logout
      end

      it "clears the sign-on status token (sst) in cookie" do
        get '/refresh_sst'
        expect(response.cookies['_sst']).to be_blank
      end
    end
  end
end
