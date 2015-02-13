require 'rails_helper'

RSpec.describe InvitationCodeService, :type => :service do
  describe ".generate" do
    it "generates an invitation code" do
      5.times do
        email = Faker::Internet.email
        code = InvitationCodeService.generate(email)
        expect(InvitationCodeService.verify(code)).to eq(email)
      end
    end
  end

  describe ".verify" do
    it "verifies an invitation code" do
      5.times do
        email = Faker::Internet.email
        code = InvitationCodeService.generate(email)
        expect(InvitationCodeService.verify(code)).to eq(email)
      end
      expect(InvitationCodeService.verify('invalid_code')).to eq(nil)
    end
  end
end
