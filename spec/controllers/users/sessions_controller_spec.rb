require 'rails_helper'

RSpec.describe Users::SessionsController, :type => :controller do
  describe "GET refresh_it" do
    context "user currently signed in" do
      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        @user = create(:user)
        @user.confirm!
        sign_in @user
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
    end
  end
end
