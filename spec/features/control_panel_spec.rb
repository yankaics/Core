require 'rails_helper'

feature "Control Panel", :type => :feature do
  before :each do
    @admin_credentials = { username: 'test_admin', password: 'password' }
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

  describe "Organization Control Panel" do
    include_context "login to admin panel"
    before do
      visit(admin_root_path)
      find('#organizations').find('a').click
    end

    scenario "Admin creats Organization", :js => false do
      click_link I18n.t(:'active_admin.new_model', model: I18n.t(:'activerecord.models.organization'))
      fill_form(:organization, attributes_for(:organization, code: "NTUST", name: "臺灣科技大學", short_name: "台科大"))
      find('#organization_submit_action').find('input').click

      expect(page).to have_content('NTUST')
      expect(page).to have_content('臺灣科技大學')
      expect(page).to have_content('台科大')

      expect(Organization.where(code: :NTUST).last).to be_a(Object)
    end

    scenario "Admin views a Organization", :js => false do
      create(:ntust_organization)
      visit(current_path)
      click_link 'NTUST'

      expect(page).to have_content('NTUST')
      expect(page).to have_content('臺灣科技大學')
      expect(page).to have_content('台科大')
    end
  end

  describe "Organization Department Control Panel" do
    include_context "login to admin panel"
    let!(:organization) { create(:organization) }
    before do
      visit(admin_root_path)
      find('#departments').find('a').click
    end

    scenario "Admin creats Organization Department", :js => false do
      click_link I18n.t(:'active_admin.new_model', { model: I18n.t(:'activerecord.models.department') })
      fill_form(:department, name: "資訊工程系", short_name: "資工系")
      find('#department_code').set('CS')
      find("option[value='#{organization.code}']").select_option
      find('#department_submit_action').find('input').click

      expect(page).to have_content('CS')

      cs = organization.departments.where(code: :CS).last

      expect(cs).to be_a(Object)
      expect(cs.organization_code).to eq(organization.code)
      expect(cs.code).to eq("CS")
      expect(cs.name).to eq("資訊工程系")
      expect(cs.short_name).to eq("資工系")
    end

    scenario "Admin views a department", :js => false do
      create(:ntust_organization)
      visit(current_path)
      click_link 'U01'

      expect(page).to have_content('U01')
      expect(page).to have_content('校長室')
    end
  end

  describe "Setting Control Panel" do
    include_context "login to admin panel"

    scenario "Admin changes settings", :js => false do
      visit(admin_root_path)
      find('#settings').find('a').click
      within("#main_content") do
        all('input[type=text]').each_with_index { |input, i| input.set "input_val#{i}" }
        all('textarea').each_with_index { |input, i| input.set "textarea_val#{i}" }
        all('input[type=checkbox]').each { |input| input.set true }
        find("input[type=submit]").click
      end
      within("#main_content") do
        all('input[type=text]').each_with_index do |input, i|
          expect(input.value).to eq "input_val#{i}"
        end
        all('textarea').each_with_index do |input, i|
          expect(input.value).to eq "textarea_val#{i}"
        end
        all('input[type=checkbox]').each do |input|
          expect(input.value).to be_truthy
        end
      end
    end
  end
end
