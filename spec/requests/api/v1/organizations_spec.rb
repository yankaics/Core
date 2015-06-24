require "rails_helper"

describe "Organizations API" do
  describe "GET /api/v1/organizations" do
    before do
      create_list(:organization, 100)
    end

    it "returns a full list of organizations" do
      get "/api/v1/organizations.json"

      expect(response).to be_success
      json = JSON.parse(response.body)

      expect(json.count).to eq(100)
    end
  end

  describe "GET /api/v1/organizations/{code}" do
    before do
      create(:ntust_organization)
    end

    it "returns data of an organization with departments included" do
      get "/api/v1/organizations/NTUST.json"

      expect(response).to be_success
      json = JSON.parse(response.body)

      expect(json['code']).to eq('NTUST')
      expect(json['departments'].first).to be_a(Hash)
    end
  end
end
