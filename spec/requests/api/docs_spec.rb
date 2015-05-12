require "rails_helper"

describe "API Docs" do
  context "global" do
    it "returns Swagger-compliant docs" do
      get '/api/docs'
      expect(response).to be_success
      json = JSON.parse(response.body)
    end
  end
end
