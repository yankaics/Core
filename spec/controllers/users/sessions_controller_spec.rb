require 'rails_helper'

RSpec.describe Users::SessionsController, :type => :controller do
  describe "GET /refresh_sst" do
    context "user currently signed in" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @user = create(:user)
        @user.confirm!
        sign_in @user
      end

      it "sets the sign-on status token (sst) in cookie" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        get :refresh_sst
        sst_string = response.cookies['_sst']
        sst = SignonStatusTokenService.decode(sst_string)
        expect(sst['id']).to eq(@user.id)
        expect(sst['uuid']).to eq(@user.uuid)
      end
    end

    context "user not currently signed in" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @user = create(:user)
        @user.confirm!
        sign_in @user
        get :refresh_sst
        expect(response.cookies).to have_key '_sst'
        sign_out @user
      end

      it "clears the sign-on status token (sst) in cookie" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        get :refresh_it
        expect(response.cookies['_sst']).to be_blank
      end
    end
  end

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
        expect(response.cookies['_identity_token']).to eq SiteIdentityTokenService.generate(@user)
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
