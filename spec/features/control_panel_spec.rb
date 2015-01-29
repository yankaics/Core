require 'rails_helper'

feature "Control Panel", :type => :feature do
  scenario "Admin signs in" do
    admin_credentials = { username: 'test_admin', password: 'password' }
    admin = create(:admin, admin_credentials)
    visit(new_admin_session_path)
    within("#login") do
      fill_in 'admin_username', with: admin_credentials[:username]
      fill_in 'admin_password', with: admin_credentials[:password]
      find("input[type=submit]").click
    end
    expect(page).to have_content I18n.t('devise.sessions.signed_in')
  end

  describe "User Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    include_context "create two organizations and four users"
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#users a').click
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

      scenario "Admin views users" do
        visit(current_path)
        expect(page).to have_content(@usr.name)
        expect(page).to have_content(@org_usr.name)
        expect(page).to have_content(@gro_usr.name)
        expect(page).to have_content(@org_gro_usr.name)
        within('.table_tools > .indexes') { click_link('Detailed Table') }
        within('.table_tools > .indexes') { click_link('Grid') }
        within('.table_tools > .scopes') { click_link('All') }
        within('.table_tools > .scopes') { click_link('Confirmed') }
        within('.table_tools > .scopes') { click_link('Unconfirmed') }
        within('.table_tools > .scopes') { click_link('Identified') }
        within('.table_tools > .scopes') { click_link('Unidentified') }
      end

      scenario "Admin views a user" do
        visit(current_path)
        click_link(@org_usr.name)
        expect(page).to have_content(@org_usr.name)
      end

      scenario "Admin updates a user" do
        visit(current_path)
        first('tbody a.edit_link').click
        first("input[type=submit]").click
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'ORG')
      end

      scenario "Admin views scoped users" do
        visit(current_path)
        expect(page).not_to have_content(@usr.name)
        expect(page).to have_content(@org_usr.name)
        expect(page).not_to have_content(@gro_usr.name)
        expect(page).to have_content(@org_gro_usr.name)
      end

      scenario "Admin views a user" do
        visit(current_path)
        click_link(@org_usr.name)
        expect(page).to have_content(@org_usr.name)
      end

      scenario "Admin updates a user" do
        visit(current_path)
        first('tbody a.edit_link').click
        first("input[type=submit]").click
      end

      scenario "Admin views a user out of scope" do
        expect { visit(admin_user_path(@gro_usr)) }.to raise_error
      end
    end
  end

  describe "Organization Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#organizations a').click
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
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
  end

  describe "Department Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :all do
      @ntust = create(:ntust_organization)
      @nthu = create(:nthu_organization)
      @ntust.reload
      @nthu.reload
    end
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#departments a').click
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

      scenario "Admin views departments", :js => false do
        visit(current_path)
        first('.sortable.col-short_name a').click
        expect(page).to have_content(@ntust.departments.order(short_name: :asc).first.name)
        expect(page).to have_content(@nthu.departments.order(short_name: :asc).first.name)
      end

      scenario "Admin views a department", :js => false do
        visit(admin_department_path(@nthu.departments.first))
      end

      scenario "Admin creates department", :js => false do
        visit(new_admin_department_path)
        within("#main_content") do
          select "國立清華大學", from: 'department_organization_code'
          fill_in 'department_code', with: "TEST01"
          fill_in 'department_name', with: "TEST 01"
          fill_in 'department_short_name', with: "TEST 01"
          fill_in 'department_parent_code', with: ""
          fill_in 'department_group', with: ""
          find('input[type=submit]').click
        end
        expect(page).to have_content('TEST01')
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'NTUST')
      end

      scenario "Admin views departments", :js => false do
        visit(current_path)
        first('.sortable.col-short_name a').click
        expect(page).to have_content(@ntust.departments.order(short_name: :asc).first.name)
        expect(page).not_to have_content(@nthu.departments.order(short_name: :asc).first.name)
      end

      scenario "Admin views a out-scoped department", :js => false do
        expect { visit(admin_department_path(@nthu.departments.first)) }.to raise_error
      end

      scenario "Admin creates department", :js => false do
        visit(new_admin_department_path)
        within("#main_content") do
          fill_in 'department_code', with: "TEST01"
          fill_in 'department_name', with: "TEST 01"
          fill_in 'department_short_name', with: "TEST 01"
          fill_in 'department_group', with: ""
          find('input[type=submit]').click
        end
        expect(page).to have_content('TEST01')
      end
    end
  end

  describe "EmailPattern Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :all do
      @ntust = create(:ntust_organization)
      @nthu = create(:nthu_organization)
      @ntust.reload
      @nthu.reload
    end
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#email_patterns a').click
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

      scenario "Admin views email_patterns", :js => false do
        visit(current_path)
        first('.sortable.col-email_regexp a').click
        expect(page).to have_content(@ntust.email_patterns.order(email_regexp: :asc).first.email_regexp)
        expect(page).to have_content(@nthu.email_patterns.order(email_regexp: :asc).first.email_regexp[0..32])
      end

      scenario "Admin views a email_pattern", :js => false do
        visit(admin_email_pattern_path(@nthu.email_patterns.first))
      end

      scenario "Admin creates email_pattern", :js => false do
        visit(new_admin_email_pattern_path)
        within("#main_content") do
          select "國立清華大學", from: 'email_pattern_organization_code'
          select "staff", from: 'email_pattern_corresponded_identity'
          fill_in 'email_pattern_email_regexp', with: "[a-z]+"
          find('input[type=submit]').click
        end
        expect(page).to have_content('[a-z]+')
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'NTUST')
      end

      scenario "Admin views email_patterns", :js => false do
        visit(current_path)
        first('.sortable.col-email_regexp a').click
        expect(page).to have_content(@ntust.email_patterns.order(email_regexp: :asc).first.email_regexp)
        expect(page).not_to have_content(@nthu.email_patterns.order(email_regexp: :asc).first.email_regexp)
      end

      scenario "Admin views a out-scoped email_pattern", :js => false do
        expect { visit(admin_email_pattern_path(@nthu.email_patterns.first)) }.to raise_error
      end

      scenario "Admin creates email_pattern", :js => false do
        visit(new_admin_email_pattern_path)
        within("#main_content") do
          select "staff", from: 'email_pattern_corresponded_identity'
          fill_in 'email_pattern_email_regexp', with: "someone@example.com.tw"
          find('input[type=submit]').click
        end
        expect(page).to have_content('someone@example.com.tw')
      end
    end
  end

  describe "UserIdentity Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :all do
      @ntust = create(:ntust_organization)
      @nthu = create(:nthu_organization)
      create(:user_identity, organization: @ntust)
      create(:user_identity, organization: @nthu)
      @ntust.reload
      @nthu.reload
    end
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#user_identities a').click
    end
    let(:user_identity_csv_file) do
      Rails.root.join('spec', 'fixtures', 'files', 'sample_user_identity.csv')
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

      scenario "Admin views user_identities", :js => false do
        visit(current_path)
        first('.sortable.col-email a').click
        expect(page).to have_content(@ntust.user_identities.order(email: :asc).first.email)
        expect(page).to have_content(@nthu.user_identities.order(email: :asc).first.email)
      end

      scenario "Admin views a user_identity", :js => false do
        visit(admin_user_identity_path(@nthu.user_identities.first))
      end

      scenario "Admin creates user_identity", :js => false do
        visit(new_admin_user_identity_path)
        within("#main_content") do
          select "國立清華大學", from: 'user_identity_organization_code'
          fill_in 'user_identity_email', with: "someone@example.com.tw"
          fill_in 'user_identity_uid', with: "someone"
          find('input[type=submit]').click
        end
        expect(page).to have_content('someone@example.com.tw')
      end

      scenario "Admin imports user_identities", :js => false do
        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file)
        find('input[type=submit]').click

        imported_user_identities = UserIdentity.last(9)

        [
          ['professor', "A Prof", 'a_prof@example.com', 'a_prof@example.com', 'D15', 'NTUST', true, true, 'D15'],
          ['professor', "Another Prof", 'another_prof@example.com', 'another_prof@example.com', 'D10', 'NTUST', true, true, 'D10'],
          ['lecturer', "A Lecturer", 'a_lecturer@example.com', 'a_lecturer@example.com', 'D15', 'NTUST', true, true, 'D15'],
          ['lecturer', "Another Lecturer", 'another_lecturer@example.com', 'another_lecturer@example.com', 'D10', 'NTUST', true, true, 'D10'],
          ['staff', "A Staff", 'a_staff@example.com', 'a_staff@example.com', 'U13', 'NTUST', true, true, 'U13'],
          ['student', "A Student", 'a_student@example.com', 'a_student@example.com', 'D15', 'NTUST', true, false, 'D15'],
          ['student', "Another Student", 'another_student@example.com', 'another_student@example.com', 'D10', 'NTUST', true, false, 'D15'],
          ['guest', "A Guest", 'a_guest@example.com', 'a_guest@example.com', nil, 'NTUST', false, false, nil],
          ['guest', "Another Guest", 'another_guest@example.com', 'another_guest@example.com', nil, 'NTUST', false, false, nil]
        ].each_with_index do |identity_data, i|
          expect(imported_user_identities[i].identity).to eq identity_data[0]
          expect(imported_user_identities[i].name).to eq identity_data[1]
          expect(imported_user_identities[i].email).to eq identity_data[2]
          expect(imported_user_identities[i].uid).to eq identity_data[3]
          expect(imported_user_identities[i].department_code).to eq identity_data[4]
          expect(imported_user_identities[i].organization_code).to eq identity_data[5]
          expect(imported_user_identities[i].permit_changing_department_in_group).to eq identity_data[6]
          expect(imported_user_identities[i].permit_changing_department_in_organization).to eq identity_data[7]
          expect(imported_user_identities[i].original_department_code).to eq identity_data[8]
        end

        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file)
        find('input[type=submit]').click

        expect(UserIdentity.where(organization_code: 'NTUST', email: 'a_prof@example.com').count).to eq 1
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'NTUST')
      end

      scenario "Admin views user_identities", :js => false do
        visit(current_path)
        first('.sortable.col-email a').click
        expect(page).to have_content(@ntust.user_identities.order(email: :asc).first.email)
        expect(page).not_to have_content(@nthu.user_identities.order(email: :asc).first.email)
      end

      scenario "Admin views a out-scoped user_identity", :js => false do
        expect { visit(admin_user_identity_path(@nthu.user_identities.first)) }.to raise_error
      end

      scenario "Admin creates user_identity", :js => false do
        visit(new_admin_user_identity_path)
        within("#main_content") do
          fill_in 'user_identity_email', with: "someone2@example.com.tw"
          fill_in 'user_identity_uid', with: "someone2"
          find('input[type=submit]').click
        end
        expect(page).to have_content('someone2@example.com.tw')
      end
    end
  end

  describe "Settings Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
      find('#users a').click
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

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

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'ORG')
      end

      scenario "Admin can't change settings", :js => false do
        visit(admin_root_path)
        expect { find('#settings').find('a').click }.to raise_error
        expect do
          visit(admin_settings_path)
          find("input[type=submit]").click
        end.to raise_error
      end
    end
  end

  describe "Applications Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
        @core_app_1 = create(:oauth_application, :owned_by_admin)
        @core_app_2 = create(:oauth_application, :owned_by_admin)
        @user_app_1 = create(:oauth_application)
        @user_app_2 = create(:oauth_application)
      end
      before :each do
        find('#doorkeeper_applications a').click
      end

      scenario "Admin views applications", :js => false do
        visit(current_path)
        first('.scope.core_apps a').click
        expect(page).to have_content(@core_app_1.name)
        expect(page).to have_content(@core_app_2.name)
        first('.scope.user_apps a').click
        expect(page).to have_content(@user_app_1.name)
        expect(page).to have_content(@user_app_2.name)
      end

      scenario "Admin views a application", :js => false do
        visit(admin_doorkeeper_application_path(Doorkeeper::Application.last))
        expect(page).to have_content(Doorkeeper::Application.last.name)
      end

      scenario "Admin creates application", :js => false do
        visit(new_admin_doorkeeper_application_path)
        within("#main_content") do
          find('input[type=submit]').click
        end
        within("#main_content") do
          fill_in 'doorkeeper_application_name', with: "TEST01"
          fill_in 'doorkeeper_application_redirect_uri', with: "urn:ietf:wg:oauth:2.0:oob"
          find('input[type=submit]').click
        end
        expect(page).to have_content(Doorkeeper::Application.last.uid)
      end

      scenario "Admin updates application", :js => false do
        visit(edit_admin_doorkeeper_application_path(Doorkeeper::Application.last))
        within("#main_content") do
          fill_in 'doorkeeper_application_name', with: ""
          find('input[type=submit]').click
        end
        within("#main_content") do
          fill_in 'doorkeeper_application_name', with: "Hello App"
          fill_in 'doorkeeper_application_sms_quota', with: "101"
          find('input[type=submit]').click
        end
        expect(page).to have_content(Doorkeeper::Application.last.uid)
        expect(Doorkeeper::Application.last.sms_quota).to eq 101
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @admin = create(:admin, scoped_organization_code: 'ORG')
      end

      scenario "Admin can't manage applications", :js => false do
        expect { visit(admin_doorkeeper_applications_path) }.to raise_error
      end
    end
  end
end

  # describe "Some Control Panel" do
  #   before(:all) { DatabaseCleaner.clean_with(:deletion) }
  #   before :each do
  #     login_as @admin, scope: :admin
  #     visit(admin_root_path)
  #     find('#users a').click
  #   end

  #   context "signed in as a root admin" do
  #     before(:all) do
  #       @admin = create(:admin)
  #     end

  #     scenario "", :js => false do
  #     end
  #   end

  #   context "signed in as a scoped admin" do
  #     before(:all) do
  #       @admin = create(:admin, scoped_organization_code: 'ORG')
  #     end

  #     scenario "", :js => false do
  #     end
  #   end
  # end
