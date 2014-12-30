require 'rails_helper'

feature "Control Panel Setting", :type => :feature do
  before :each do
    @admin_credentials = { username: 'test_admin', password: 'password' }
    @admin = create(:admin, @admin_credentials)
    login_as @admin, scope: :admin
  end

  scenario "Admin changes settings", :js => false do
    visit(admin_root_path)
    find('#setting').find('a').click
    within("#main_content") do
      all('input[type=text]').each_with_index { |input, i| input.set "input_val#{i}" }
      all('textarea').each_with_index { |input, i| input.set "textarea_val#{i}" }
      all('input[type=checkbox]').each_with_index { |input| input.set true }
      find("input[type=submit]").click
    end
    within("#main_content") do
      all('input[type=text]').each_with_index do |input, i|
        expect(input.value).to eq "input_val#{i}"
      end
      all('textarea').each_with_index do |input, i|
        expect(input.value).to eq "textarea_val#{i}"
      end
      all('input[type=checkbox]').each_with_index do |input|
        expect(input.value).to be_truthy
      end
    end
  end
end
