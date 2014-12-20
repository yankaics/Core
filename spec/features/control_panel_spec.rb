require 'rails_helper'

feature "Control Panel", :type => :feature do
  before :each do
    @admin_credentials = {username: 'test_admin', password: 'password'}
    @admin = create(:admin, @admin_credentials)
  end

  scenario "Admin signs in" do
    visit(new_admin_session_path)
    within("#login") do
      fill_in 'admin_username', with: @admin_credentials[:username]
      fill_in 'admin_password', with: @admin_credentials[:password]
      find("input[type=submit]").click
    end
    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end
end
