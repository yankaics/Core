require "rails_helper"

describe "RSA key requests" do
  describe "GET /_rsa.pub" do
    it "returns the core RSA public key" do
      get '/_rsa.pub'
      expect(response).to be_success
      rsa = response.body
      expect(rsa).to eq(CoreRSAKeyService.public_key_string)
    end
  end
end
