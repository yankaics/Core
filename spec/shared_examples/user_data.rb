require 'rails_helper'

RSpec.shared_examples "a user data object" do
  let(:user_obj) do
    if described_class == User
      create(:user)
    elsif described_class == UserData
      create(:user).data
    else
      fail "Unknown UserObj"
    end
  end

  describe "#birth_date" do
    before do
      user_obj.birth_year = 2000
      user_obj.birth_month = 12
      user_obj.birth_day = 25
    end

    it "returns the user's birthday as a Date" do
      expect(user_obj.birth_date).to eq Date.new(2000, 12, 25)
    end
  end

  describe "#birth_date=" do
    let(:user) { create(:user) }

    it "sets the user's birthday as a Date" do
      birthday = 18.years.ago
      user_obj.birth_date = birthday
      expect(user_obj.birth_year).to eq birthday.year
      expect(user_obj.birth_month).to eq birthday.month
      expect(user_obj.birth_day).to eq birthday.day

      user_obj.birth_date = nil
      expect(user_obj.birth_year).to eq nil
      expect(user_obj.birth_month).to eq nil
      expect(user_obj.birth_day).to eq nil
    end
  end
end
