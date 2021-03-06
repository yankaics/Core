require 'rails_helper'

feature "Control Panel", :type => :feature, :retry => 3 do
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

      scenario "Admin test login as a unconfirmed user" do
        @usr.confirmed_at = nil
        @usr.save!
        visit(admin_users_path('q[id_equals]' => "#{@usr.id}"))
        first('.col-testing .login').click
        cookies = page.driver.request.cookies
        page.driver.post(testing_user_sessions_path(id: @usr.id))
        expect(cookies['_sst']).to be_blank
        expect(cookies['_identity_token']).to be_blank
        visit(my_account_path)
        expect(page).not_to have_content(@usr.name)
        expect(page).not_to have_content(@usr.email)
      end

      scenario "Admin test login as a confirmed user" do
        @usr.confirm!
        visit(admin_users_path('q[id_equals]' => "#{@usr.id}"))
        first('.col-testing .login').click
        cookies = page.driver.request.cookies
        page.driver.post(testing_user_sessions_path(id: @usr.id))
        expect(cookies['_sst']).not_to be_blank
        expect(cookies['_identity_token']).not_to be_blank
        visit(my_account_path)
        expect(page).to have_content(@usr.name)
        expect(page).to have_content(@usr.email)
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

      scenario "Admin can't test login as a user" do
        @usr.confirm!
        expect do
          page.driver.post(testing_user_sessions_path(id: @usr.id))
        end.to raise_error

        cookies = page.driver.request.cookies
        expect(cookies['_sst']).to be_blank
        expect(cookies['_identity_token']).to be_blank
        visit(my_account_path)
        expect(page).not_to have_content(@usr.name)
        expect(page).not_to have_content(@usr.email)
      end
    end
  end

  describe "Data API Control Panel" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    let(:api_data_stores_csv_file) do
      Rails.root.join('spec', 'fixtures', 'files', 'api_data_stores.csv')
    end

    context "signed in as a root admin" do
      before(:each) do
        @admin = create(:admin)
        login_as @admin, scope: :admin
        visit(admin_data_apis_path)
      end

      scenario "Admin views a Data API", :js => true do
        data_api = create(:data_api)
        visit(current_path)
        click_link data_api.name
        expect(page).to have_content(data_api.name)
        expect(page).to have_content(data_api.path)
        data_api.schema.each do |k, v|
          expect(page).to have_content(k)
        end
      end

      scenario "Admin creates a Data API", :js => true do
        click_link I18n.t(:'active_admin.new_model', model: I18n.t(:'activerecord.models.data_api'))

        within("#main_content") do
          fill_in 'data_api_name', with: "my_new_api"
          fill_in 'data_api_table_name', with: "my_new_apis"
          fill_in 'data_api_path', with: "my_apis/my_new_api"

          within(".data_api_schema_table") do
            within("tbody tr:nth-child(1)") do
              find('.name').set 'my_string'
              find('.type').set 'string'
            end
            first('a.add').click
            within("tbody tr:nth-child(2)") do
              find('.name').set 'my_int'
              find('.type').set 'integer'
              find('.index').set true
            end
            first('a.add').click
            within("tbody tr:nth-child(3)") do
              find('.name').set 'unused_int'
              find('.type').set 'integer'
            end
            first('a.add').click
            within("tbody tr:nth-child(4)") do
              find('.name').set 'my_bool'
              find('.type').set 'boolean'
            end
            within("tbody tr:nth-child(3)") do
              first('a.delete').click
            end
          end

          first('#data_api_submit_action').find('input').click
        end

        expect(page).to have_content('my_int')
        expect(page).to have_content('my_string')
        expect(page).not_to have_content('unused_int')
        expect(page).to have_content('my_bool')

        data_api = DataAPI.last
        expect(data_api.schema['my_int']['index']).to eq(true)
        data_api.data_model.create(my_int: 1, my_string: 'Hi', my_bool: true)

        expect(data_api.data_model.last.my_int).to be_a(Integer)
        expect(data_api.data_model.last.my_string).to be_a(String)
        expect(data_api.data_model.last.my_bool).to be_a(TrueClass)
      end

      scenario "Admin updates a Data API", :js => true do
        Timecop.scale(3600)

        data_api = create(:data_api)
        visit(edit_admin_data_api_path(data_api))

        within("#main_content") do
          fill_in 'data_api_name', with: "my_todo_list"
          fill_in 'data_api_table_name', with: "my_todo_lists"
          fill_in 'data_api_table_name', with: "my_todos"
          fill_in 'data_api_path', with: "my/todos"

          within(".data_api_schema_table") do
            within("tbody tr:nth-child(2)") do
              first('a.delete').click
            end
            first('a.add').click
            within("tbody tr:nth-child(2)") do
              find('.name').set 'done'
              find('.type').set 'boolean'
              find('.index').set true
            end
          end
          first('#data_api_submit_action').find('input').click
        end

        expect(page).to have_content('schema')
        expect(page).to have_content('name')
        expect(page).to have_content('done')

        # we need to confirm our changes
        data_api = DataAPI.find(data_api.id)
        expect(data_api.table_name).not_to eq('my_todo_list')
        first('#data_api_submit_action').find('input').click

        expect(page).to have_content('name')
        expect(page).to have_content('done')

        data_api = DataAPI.find(data_api.id)
        expect(data_api.schema['done']['index']).to eq(true)
        data_api.data_model.create(name: 'sleep', done: false)

        # Another test
        data_api = create(:data_api)
        visit(edit_admin_data_api_path(data_api))

        within("#main_content") do
          within(".data_api_schema_table") do
            within("tbody tr:nth-child(2)") do
              first('a.delete').click
            end
            first('a.add').click
            within("tbody tr:nth-child(2)") do
              find('.name').set 'my_awesome_attribute'
              find('.type').set 'string'
            end
          end
          first('#data_api_submit_action').find('input').click
        end

        expect(page).to have_content('my_awesome_attribute')

        # we need to confirm our changes
        data_api = DataAPI.find(data_api.id)
        expect(data_api.columns).not_to include(:my_awesome_attribute)
        first('#data_api_submit_action').find('input').click

        expect(page).to have_content('my_awesome_attribute')

        data_api = DataAPI.find(data_api.id)
        data_api.data_model.create!(my_awesome_attribute: 'awesome')

        # the data API data control panel should be updated too
        visit(admin_data_api_data_path(data_api))
        expect(page).to have_content('My Awesome Attribute')

        # Another test
        data_api = create(:data_api)
        visit(edit_admin_data_api_path(data_api))

        within("#main_content") do
          fill_in 'data_api_description', with: "hello world"
          first('#data_api_submit_action').find('input').click
        end

        expect(page).to have_content('hello world')

        # we don't need to confirm our changes
        data_api = DataAPI.find(data_api.id)
        expect(data_api.description).to eq("hello world")

        Timecop.scale(1)
        Timecop.return
      end

      scenario "Admin manages data of an Data API", :js => false do
        data_api = create(:data_api, schema: { string: { type: 'string' }, text: { type: 'text' }, boolean: { type: 'boolean' } })
        visit(admin_data_api_data_path(data_api_id: data_api.id))
        click_link I18n.t(:'active_admin.new_model', model: I18n.t(:'activerecord.models.data_api_api_data'))
        fill_in 'data_string', with: "Hello World"
        fill_in 'data_text', with: "Have a good day!"
        check 'data_boolean'
        find('input[type=submit]').click
        expect(data_api.data_model.first.string).to eq("Hello World")
        expect(data_api.data_model.first.text).to eq("Have a good day!")
        expect(data_api.data_model.first.boolean).to be(true)
        expect(page).to have_content("Hello World")
        visit(admin_data_api_data_path(data_api_id: data_api.id))
        expect(page).to have_content("Hello World")
      end

      scenario "Admin imports data to an Data API", :js => false do
        data_api = create(:data_api, name: 'stores', table_name: 'stores', path: 'stores', schema: { code: { type: 'string', null: false, unique: true }, name: { type: 'string', null: false }, location_latitude: { type: 'string' }, location_longitude: { type: 'string' }, open_at: { type: 'integer' }, close_at: { type: 'integer' }, description: { type: 'text' } })
        visit(import_admin_data_api_data_path(data_api_id: data_api.id))
        attach_file('active_admin_import_model_file', api_data_stores_csv_file)
        find('input[type=submit]').click

        expect(data_api.data_model.first.name).to eq('摩斯漢堡')
        expect(data_api.data_model.second.location_latitude).to eq('25.022872')
        expect(data_api.data_model.last.close_at).to eq(2399)
      end
    end

    context "signed in as a scoped admin" do
      before(:each) do
        @admin = create(:admin, :scoped)
        login_as @admin, scope: :admin
        visit(admin_data_apis_path)
      end

      scenario "Admin can't view a global Data API", :js => true do
        data_api = create(:data_api)
        visit(current_path)
        expect(page).not_to have_content(data_api.name)
      end

      scenario "Admin creates a Data API", :js => true do
        click_link I18n.t(:'active_admin.new_model', model: I18n.t(:'activerecord.models.data_api'))

        within("#main_content") do
          fill_in 'data_api_name', with: "my_simple_api"
          fill_in 'data_api_table_name', with: "my_simple_apis"
          fill_in 'data_api_path', with: "my_apis/my_simple_api"

          within(".data_api_schema_table") do
            within("tbody tr:nth-child(1)") do
              find('.name').set 'my_string'
              find('.type').set 'string'
            end
          end

          first('#data_api_submit_action').find('input').click
        end

        expect(page).to have_content('my_string')

        data_api = DataAPI.last
        expect(data_api.organization).to eq(@admin.organization)
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
        expect(page).to have_content(@ntust.email_patterns.order(email_regexp: :asc).first.email_regexp[0..32])
        expect(page).to have_content(@nthu.email_patterns.order(email_regexp: :asc).first.email_regexp[0..32])
      end

      scenario "Admin views a email_pattern", :js => false do
        visit(admin_email_pattern_path(@nthu.email_patterns.first))
      end

      scenario "Admin creates email_pattern", :js => false do
        visit(new_admin_email_pattern_path)
        within("#main_content") do
          select "國立清華大學", from: 'email_pattern_organization_code'
          select UserIdentity.human_enum_value('identity', 'staff'), from: 'email_pattern_corresponded_identity'
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
        expect(page).to have_content(@ntust.email_patterns.order(email_regexp: :asc).first.email_regexp[0..32])
        expect(page).not_to have_content(@nthu.email_patterns.order(email_regexp: :asc).first.email_regexp[0..32])
      end

      scenario "Admin views a out-scoped email_pattern", :js => false do
        expect { visit(admin_email_pattern_path(@nthu.email_patterns.first)) }.to raise_error
      end

      scenario "Admin creates email_pattern", :js => false do
        visit(new_admin_email_pattern_path)
        within("#main_content") do
          select UserIdentity.human_enum_value('identity', 'staff'), from: 'email_pattern_corresponded_identity'
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
    let(:user_identity_csv_file_2) do
      Rails.root.join('spec', 'fixtures', 'files', 'sample_user_identity_2.csv')
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

      scenario "Admin re-imports user_identities", :js => false do
        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file)
        find('input[type=submit]').click

        expect(UserIdentity.find_by(email: 'a_student@example.com').name).to eq('A Student')

        # link an identity to a user
        user = create(:user)
        user.confirm!
        ue = user.emails.create(email: 'a_prof@example.com')
        ue.confirm!
        user.reload
        expect(user.primary_identity.name).to eq('A Prof')

        # create a user with a currently unrecognized email
        user2 = create(:user)
        user2.confirm!
        ue = user2.emails.create(email: 'a_new_prof@example.com')
        ue.confirm!
        user2.reload
        expect(user2.primary_identity).to be_nil

        # create a user with a auto generated identity
        create(:email_pattern, organization: Organization.find_by(code: 'NTUST'), priority: 1, corresponded_identity: UserIdentity::IDENTITIES[:staff], email_regexp: '^(?<uid>.+)@example.com$')
        user3 = create(:user)
        user3.confirm!
        ue = user3.emails.create(email: 'another_new_prof@example.com')
        ue.confirm!
        user3.reload
        expect(user3.organization_code).to eq('NTUST')

        # import a file with duplicated entries
        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file_2)
        find('input[type=submit]').click

        user.reload
        user2.reload
        user3.reload

        # existing identity will be updated
        expect(UserIdentity.find_by(email: 'a_student@example.com').name).to eq('A Duplicated Student')
        # linked identity will not be updated
        expect(user.primary_identity.name).to eq('A Prof')
        # new identity will be automatically linked
        expect(user2.primary_identity.name).to eq('A New Prof')
        # new identity will be automatically linked, replaceing the generated ones
        expect(user3.primary_identity.name).to eq('Another New Prof')
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

      scenario "Admin imports user_identities", :js => false do
        UserIdentity.delete_all

        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file)
        find('input[type=submit]').click

        imported_user_identities = UserIdentity.last(9)

        expect(imported_user_identities.count).to eq(9)
      end

      scenario "Admin imports out-scoped user_identities", :js => false do
        UserIdentity.delete_all
        @admin.update_attribute(:scoped_organization_code, 'NTHU')

        visit(import_admin_user_identities_path)
        attach_file('active_admin_import_model_file', user_identity_csv_file)
        find('input[type=submit]').click

        imported_user_identities = UserIdentity.last(9)

        expect(imported_user_identities.count).to eq(0)
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

  describe "Admins" do
    before(:all) { DatabaseCleaner.clean_with(:deletion) }
    before :each do
      login_as @admin, scope: :admin
      visit(admin_root_path)
    end

    context "signed in as a root admin" do
      before(:all) do
        @admin = create(:admin)
      end

      scenario "Admin views Admins", :js => false do
        find('#admins a').click
        expect(page).to have_content(@admin.username)
      end

      scenario "Admin creates Admin", :js => false do
        visit(new_admin_admin_path)
        within("#main_content") do
          fill_in 'admin_username', with: Faker::Internet.user_name
          fill_in 'admin_email', with: Faker::Internet.email
          fill_in 'admin_password', with: 'abc123'
          fill_in 'admin_password_confirmation', with: 'abc123'
          find('input[type=submit]').click
        end
        expect(page).to have_content(Admin.last.username)
      end
    end

    context "signed in as a scoped admin" do
      before(:all) do
        @org = create(:organization, code: 'ORG')
        @admin = create(:admin, scoped_organization_code: 'ORG')
      end

      # scenario "", :js => false do
      # end
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
