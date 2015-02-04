require 'rails_helper'

RSpec.describe OAuth::AuthorizationsController, :type => :controller do
  let(:client) { create(:oauth_application) }
  let(:user) { create(:user) }

  context "user currently signed in" do
    before do
      Timecop.freeze
      user.confirm!
      sign_in user
    end
    after do
      Timecop.return
    end

    describe "POST #create" do
      before do
        post :create, client_id: client.uid, response_type: 'token', redirect_uri: client.redirect_uri
      end

      it "sets the identity_token in cookie" do
        expect(response.cookies['_identity_token']).to eq SiteIdentityToken::MaintainService.generate_token(user)
      end
    end

    describe "GET #new" do
      before do
        get :new, client_id: client.uid, response_type: 'token', redirect_uri: client.redirect_uri
      end

      it "sets the identity_token in cookie" do
        expect(response.cookies['_identity_token']).to eq SiteIdentityToken::MaintainService.generate_token(user)
      end
    end
  end
end
