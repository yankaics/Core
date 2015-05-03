require 'rails_helper'

feature "User Verificate", :type => :feature, :retry => 3 do
  before :each do
    @ntust = create(:ntust_organization)
    @nthu = create(:nthu_organization)
    @user_a1 = create(:user)
    @user_a2 = create(:user)
    @user_b1 = create(:user)
    @user_b2 = create(:user)
    @user_a1.confirm!
    @user_a2.confirm!
    @user_b1.confirm!
    @user_b2.confirm!
  end

  scenario "User verifies an email matching an EmailPattern and changes the department", :js => true do
    # Login and go to the new email verification page
    login_as @user_a1
    visit(new_my_account_email_path)

    # Try to enter an email and waites for the department select dropdown to appear
    tries = 10
    until page.has_content?('電資學士班')
      fill_in('user_email_email', with: 'b10132023@mail.ntust.edu.tw')
      execute_script("$('input[type=submit]')[0].focus()")
      sleep(1)
      tries -= 1
      break if tries == 0
    end

    expect(page).to have_content('國立臺灣科技大學')
    expect(page).to have_content('電資學士班')

    # Select an different department
    within 'select#department-select', visible: false do
      find('option[value=D10]', visible: false).select_option
    end

    first("input[type=submit]").click

    sleep(1)

    # An new UserEmail should be created
    new_email = @user_a1.unconfirmed_emails.last
    expect(new_email.email).to eq 'b10132023@mail.ntust.edu.tw'
    expect(new_email.department_code).to eq 'D10'

    # Find the confirmation_path in identity confirmation email
    confirmation_path = open_last_email.body.match(/user_emails\/confirmation\?confirmation_token=[^"]+/)

    # Record the original_identity_token
    visit('/refresh_it')
    original_identity_token = page.driver.cookies['_identity_token']

    # Visiting the confirmation_path should confirms that email
    expect do
      visit "/#{confirmation_path}"
      new_email.reload
    end.to change { new_email.confirmed? }.from(false).to(true)

    @user_a1.reload

    # And creates the corresponding identity
    expect(@user_a1.identities.first.organization_code).to eq 'NTUST'
    expect(@user_a1.identities.first.uid).to eq 'b10132023'
    expect(@user_a1.identities.first.original_department_code).to eq 'D32'
    expect(@user_a1.identities.first.department_code).to eq 'D10'  # different department selected during creation
    expect(@user_a1.identities.first.identity_detail).to eq 'bachelor'
    expect(@user_a1.identities.first.started_at.to_s).to eq '2012-09-01'
    expect(@user_a1.identities.first.permit_changing_department_in_group).to be true
    expect(@user_a1.identities.first.permit_changing_department_in_organization).to be false

    expect(@user_a1.primary_identity).to eq @user_a1.identities.first
    expect(@user_a1.organization_name).to eq '國立臺灣科技大學'
    expect(@user_a1.department_name).to eq '工商業設計系'

    # The identity_token is expected to bo refreshed by the way
    expect(page.driver.cookies['_identity_token']).not_to eq(original_identity_token)

    logout(:user)
  end

  scenario "User verifies an email with predefined identity", :js => true do
    # Create the predefined identity
    user_identity = create(:user_identity)

    # Login to the new email verification page and creates it
    login_as @user_b2
    visit(new_my_account_email_path)
    fill_in('user_email_email', with: user_identity.email)

    sleep(1)

    first("input[type=submit]").click

    sleep(1)

    # An new UserEmail should be created
    new_email = @user_b2.unconfirmed_emails.last
    expect(new_email.email).to eq user_identity.email

    # Record the original_identity_token
    visit('/refresh_it')
    original_identity_token = page.driver.cookies['_identity_token']

    # Find the confirmation_path in identity confirmation email
    confirmation_path = open_last_email.body.match(/user_emails\/confirmation\?confirmation_token=[^"]+/)

    # Visiting the confirmation_path should confirms that email
    expect do
      visit "/#{confirmation_path}"
      new_email.reload
    end.to change { new_email.confirmed? }.from(false).to(true)

    @user_b2.reload

    # And links the corresponding identity
    expect(@user_b2.primary_identity).to eq user_identity

    # The identity_token is expected to bo refreshed by the way
    expect(page.driver.cookies['_identity_token']).not_to eq(original_identity_token)

    logout(:user)
  end

  scenario "User verifies an email with predefined identity and changes the department", :js => true do
    # Create the predefined identity
    user_identity = create(:user_identity, organization: @ntust, department: @ntust.departments.find_by(name: '學務處'), permit_changing_department_in_organization: true, permit_changing_department_in_group: true)

    # Login and go to the new email verification page
    login_as @user_b1
    visit(new_my_account_email_path)

    # Try to enter an email and waites for the department select dropdown to appear
    tries = 10
    until page.has_content?('學務處')
      fill_in('user_email_email', with: user_identity.email)
      execute_script("$('input[type=submit]')[0].focus()")
      sleep(1)
      tries -= 1
      break if tries == 0
    end

    expect(page).to have_content('國立臺灣科技大學')
    expect(page).to have_content('學務處')

    # Select an different department
    within 'select#department-select', visible: false do
      find('option[value=D10]', visible: false).select_option
    end

    first("input[type=submit]").click

    sleep(1)

    # An new UserEmail should be created
    new_email = @user_b1.unconfirmed_emails.last
    expect(new_email.email).to eq user_identity.email

    # Find the confirmation_path in identity confirmation email
    confirmation_path = open_last_email.body.match(/user_emails\/confirmation\?confirmation_token=[^"]+/)

    # Record the original_identity_token
    visit('/refresh_it')
    original_identity_token = page.driver.cookies['_identity_token']

    # Visiting the confirmation_path should confirms that email
    expect do
      visit "/#{confirmation_path}"
      new_email.reload
    end.to change { new_email.confirmed? }.from(false).to(true)

    @user_b1.reload

    # And links the corresponding identity
    expect(@user_b1.primary_identity).to eq user_identity
    expect(@user_b1.organization_name).to eq '國立臺灣科技大學'
    expect(@user_b1.department_name).to eq '工商業設計系'

    # The identity_token is expected to bo refreshed by the way
    expect(page.driver.cookies['_identity_token']).not_to eq(original_identity_token)

    logout(:user)
  end
end
