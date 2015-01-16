require 'rails_helper'

feature "User Verificate", :type => :feature do
  before :all do
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

  scenario "User verifies an email", :js => true do
    login_as @user_a1
    visit(new_my_account_email_path)

    until page.has_content?('電資學士班')
      fill_in('user_email_email', with: 'b10132023@mail.ntust.edu.tw')
      execute_script("$('input[type=submit]')[0].focus()")
      sleep(2.3)
    end

    expect(page).to have_content('國立臺灣科技大學')
    expect(page).to have_content('電資學士班')

    within 'select#department-select', visible: false do
      find('option[value=D10]', visible: false).select_option
    end

    first("input[type=submit]").click

    sleep(1)

    new_email = @user_a1.unconfirmed_emails.last
    expect(new_email.email).to eq 'b10132023@mail.ntust.edu.tw'
    expect(new_email.department_code).to eq 'D10'

    confirmation_path = open_last_email.body.match /user_emails\/confirmation\?confirmation_token=[^"]+/

    expect {
      visit "/#{confirmation_path}"
      new_email.reload
    }.to change{ new_email.confirmed? }.from(false).to(true)

    @user_a1.reload

    expect(@user_a1.identities.first.organization_code).to eq 'NTUST'
    expect(@user_a1.identities.first.uid).to eq 'b10132023'
    expect(@user_a1.identities.first.original_department_code).to eq 'D32'
    expect(@user_a1.identities.first.department_code).to eq 'D10'
    expect(@user_a1.identities.first.identity_detail).to eq 'bachelor'
    expect(@user_a1.identities.first.started_at.to_s).to eq '2012-09-01'
    expect(@user_a1.identities.first.permit_changing_department_in_group).to be true
    expect(@user_a1.identities.first.permit_changing_department_in_organization).to be false

    expect(@user_a1.primary_identity).to eq @user_a1.identities.first
    expect(@user_a1.organization.name).to eq '國立臺灣科技大學'
    expect(@user_a1.department.name).to eq '工商業設計系'
    expect(@user_a1.organization.name).to eq '國立臺灣科技大學'
  end
end
