require 'rails_helper'

RSpec.describe CoreSessionsController, :type => :controller do
  describe "GET refresh_it" do
    context "user currently signed in" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @user = create(:user)
        @user.confirm!
        sign_in @user
      end

      it "sets the identity_token in cookie" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        get :refresh_it
        expect(response.cookies['_identity_token']).to eq SiteIdentityToken::MaintainService.generate_token(@user)
      end
    end

    context "user not currently signed in" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @user = create(:user)
        @user.confirm!
        sign_in @user
        get :refresh_it
        expect(response.cookies).to have_key '_identity_token'
        sign_out @user
      end

      it "clears the identity_token in cookie" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        get :refresh_it
        expect(response.cookies['_identity_token']).to be_blank
      end
    end
  end
end
