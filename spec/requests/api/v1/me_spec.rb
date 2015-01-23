require "rails_helper"

describe "Me API" do
  context "with no token" do
    it "returns error" do
      get '/api/v1/me.json'
      expect(response).not_to be_success
    end
  end

  context "with a token with public scope" do
    before do
      @token = create(:oauth_access_token)
    end
    it "returns the data of current user" do
      get "/api/v1/me.json?access_token=#{@token.token}"

      expect(response).to be_success
      json = JSON.parse(response.body)
      expect(json['name']).to eq @token.resource_owner.name
    end
  end
end
