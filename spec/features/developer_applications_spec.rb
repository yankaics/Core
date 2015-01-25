require 'rails_helper'

feature "Developer Applications", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
    login_as @user
  end

  scenario "User creates an Application" do
    visit(applications_path)
    first('a[href$="applications/new"]').click

    application_data = attributes_for(:oauth_application)
    fill_in('doorkeeper_application_name', with: application_data[:name])
    fill_in('doorkeeper_application_redirect_uri', with: application_data[:redirect_uri])
    first("input[type=submit]").click

    created_app = Doorkeeper::Application.last
    expect(created_app.name).to eq application_data[:name]
    expect(created_app.redirect_uri).to eq application_data[:redirect_uri]
  end
end
