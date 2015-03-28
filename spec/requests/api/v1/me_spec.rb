require "rails_helper"

describe "Me API" do
  context "with no token" do
    it "returns error" do
      get '/api/v1/me.json'
      expect(response).not_to be_success
    end
  end

  context "with a token contains public scope" do
    before do
      @token = create(:oauth_access_token)
    end

    it "returns the data of current user" do
      get "/api/v1/me.json?access_token=#{@token.token}"

      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['name']).to eq @token.resource_owner.name
      expect(json['id']).not_to be_blank
      expect(json['uuid']).not_to be_blank
      expect(json).not_to have_key 'email'
      expect(json).not_to have_key 'updated_at'
      expect(json).not_to have_key 'fbid'
      expect(json).not_to have_key 'brief'
      expect(json).not_to have_key 'organization'
    end
  end

  {
    'email' => %w(email),
    'account' => %w(sign_in_count last_sign_in_at),
    'facebook' => %w(fbid),
    'info' => %w(birth_month motto),
    'identity' => %w(emails identities organizations department uid identity)
  }.each do |scope, attrs|

    context "with a token contains #{scope} scope" do
      before do
        @token = create(:oauth_access_token, scopes: "public #{scope}")
      end

      attrs.each do |attr|
        it "returns the #{attr} of current user" do
          get "/api/v1/me.json?access_token=#{@token.token}"

          expect(response).to be_success
          json = JSON.parse(response.body)
          expect(json).to have_key attr
        end
      end
    end
  end
end
