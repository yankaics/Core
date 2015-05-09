require 'rails_helper'

feature "API Docs", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
  end

  feature "API Explorer" do
    scenario "Logined user uses the API Explorer", :js => true do
      visit(api_explorer_path)
      expect(page).to have_content('OAuth')
    end
  end
end
