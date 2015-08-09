require 'rails_helper'

feature "User Auth", :type => :feature, :retry => 3 do
  before do
    ENV['FB_APP_ADDITIONAL_SCOPES'] = 'user_friends,user_birthday'
    ActiveJob::Base.queue_adapter = :inline

    stub_request(:get, "https://graph.facebook.com/me?access_token=mock_token&fields=id,email,name,picture.height(500).width(500),cover,gender,link,devices,friends.limit(50000),birthday,age_range&locale=zh-TW")
      .to_return(:status => 200, :body => (<<-eod
{
  "id": "87654321",
  "name": "FB User",
  "picture": {
    "data": {
      "height": 720,
      "is_silhouette": false,
      "url": "https://picture.com/picture",
      "width": 720
    }
  },
  "gender": "male",
  "link": "https://www.facebook.com/app_scoped_user_id/87654321/",
  "devices": [
    {
      "os": "Android"
    },
    {
      "hardware": "iPad",
      "os": "iOS"
    }
  ],
  "friends": {
    "data": [
      {
        "name": "Facebook User2",
        "id": "12345678"
      },
      {
        "name": "Facebook User3",
        "id": "87655678"
      }
    ],
    "paging": {
      "next": "..."
    },
    "summary": {
      "total_count": 52
    }
  },
  "birthday": "05/02/1994",
  "age_range": {
    "min": 21
  }
}
eod
      ), :headers => {})
  end

  scenario "new User signs in with Facebook" do
    Settings.skip_3rd_party_login_account_update = false

    # Go to the login page and click on 'login_with_facebook' button
    visit(new_user_session_path)
    click_on('login_with_facebook', match: :first)

    # Get the newly created user, he/she should be confirmed
    user = User.last
    expect(user).to be_confirmed
    expect(user.name).to eq('FB User')
    expect(user.gender).to eq('male')
    expect(user.avatar_url).to eq('https://picture.com/picture')
    expect(user.birth_month).to eq(5)
    expect(user.birth_day).to eq(2)
    expect(user.birth_year).to eq(1994)
    expect(user.fb_friends).to have_key('data')
    expect(user.fb_friends).not_to have_key('paging')
    expect(user.fb_devices.length).to eq(2)

    # Users should be redirected to update their account after first login
    expect(current_path).to eq edit_user_registration_path

    # Change account info
    fill_in('user-email-input', with: 'someone@some.where')
    fill_in('user-password-input', with: 'abcd1234')
    fill_in('user-password_confirmation-input', with: 'abcd1234')
    find("input[type=submit]").click
    user.reload

    # The user can use the new password
    expect(user.valid_password?('abcd1234')).to be true

    # Find the email confirmation_path from the user's email inbox
    confirmation_path = open_last_email.body.match(/confirmation\?confirmation_token=[^"]+/)

    # Confirm the email by visiting the confirmation path
    visit "/#{confirmation_path}"
    user.reload

    expect(user.email).to eq('someone@some.where')

    # On background: sign-on status token (sst) cookie should be set
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(user.id)
    expect(sst['uuid']).to eq(user.uuid)

    # After logout
    visit('/logout')

    # On background: sign-on status token (sst) cookie should be cleared
    expect(page.driver.request.cookies['_sst'])
      .to be_blank
  end

  scenario "new User signs in with Facebook with new account update disabled" do
    Settings.skip_3rd_party_login_account_update = true

    # Go to the login page and click on 'login_with_facebook' button
    visit(new_user_session_path)
    click_on('login_with_facebook', match: :first)

    # Get the newly created user, he/she should be confirmed
    user = User.last
    expect(user).to be_confirmed
    expect(user.name).to eq('FB User')
    expect(user.gender).to eq('male')
    expect(user.avatar_url).to eq('https://picture.com/picture')
    expect(user.birth_month).to eq(5)
    expect(user.birth_day).to eq(2)
    expect(user.birth_year).to eq(1994)
    expect(user.fb_friends).to have_key('data')
    expect(user.fb_friends).not_to have_key('paging')
    expect(user.fb_devices.length).to eq(2)

    # Users should be redirected to the new email page after their first login
    expect(current_path).to eq new_my_account_email_path

    # On background: sign-on status token (sst) cookie should be set
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(user.id)
    expect(sst['uuid']).to eq(user.uuid)

    # After logout
    visit('/logout')

    # On background: sign-on status token (sst) cookie should be cleared
    expect(page.driver.request.cookies['_sst'])
      .to be_blank
  end

  scenario "returning User signs in with Facebook" do
    # An existing user with identity, but not linked with an FB account
    user = create(:user, :with_identity, email: 'mock_user@facebook.com')

    # Go to the login page and click on 'login_with_facebook' button
    # this should login the user with that corresponding email,
    # and links the user with his/her FB account
    visit(new_user_session_path)
    click_on('login_with_facebook', match: :first)
    user.reload
    expect(user.fbid).to eq '87654321'

    # expect(page).to ...
    # Old users should not be redirected to the new email page after login
    expect(current_path).not_to eq new_my_account_email_path

    # On background: sign-on status token (sst) cookie should be set
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(user.id)
    expect(sst['uuid']).to eq(user.uuid)

    # On background: identity_token cookie should be set
    # (ignoring the small time difference)
    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityTokenService.generate(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityTokenService.generate(user)[0..-4]

    # After logout
    visit('/logout')

    # On background: sign-on status token (sst) cookie should be cleared
    expect(page.driver.request.cookies['_sst'])
      .to be_blank

    # On background: identity_token cookie should be cleared
    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank
  end

  scenario "new User signs up with email" do
    # Prepare the new user's credentials
    user_rigister_credentials = attributes_for(:user).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)

    # Go to the login page and fill the registration form
    visit(new_user_session_path)
    within ".registration" do
      fill_form_and_submit(:user, user_rigister_credentials)
    end

    # Get the newly created user
    user = User.last
    # And finds his/her account confirmation_path from his/her email inbox
    confirmation_path = open_last_email.body.match(/confirmation\?confirmation_token=[^"]+/)

    # Logging in without the account confirmed is illegal
    visit(new_user_session_path)
    within ".login" do
      fill_form(:user, user_login_credentials)
      find('form input[type=submit]').click
    end
    # expect(page).to fail...

    # Confirm the account by visiting the confirmation path
    expect do
      visit "/#{confirmation_path}"
      user.reload
    end.to change { user.confirmed? }.from(false).to(true)

    # New users are signed in automatically and redirected to
    # new_my_account_email_path after clicking the confirmation link
    expect(current_path).to eq(new_my_account_email_path)

    # expect(page).to ...

    # On background: sign-on status token (sst) cookie should be set
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(user.id)
    expect(sst['uuid']).to eq(user.uuid)
    expect(sst['updated_at']).to eq(user.updated_at.to_i)
    expect(sst['updated_at']).to eq(user.updated_at.to_i)

    # On background: identity_token cookie should be maintained...
    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityTokenService.generate(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityTokenService.generate(user)[0..-4]

    visit('/logout')

    # On background: sign-on status token (sst) cookie should be cleared
    expect(page.driver.request.cookies['_sst'])
      .to be_blank

    # On background: identity_token cookie should be maintained...
    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank

    # Login with the confirmed account will success
    visit(new_user_session_path)
    within ".login" do
      fill_form(:user, user_login_credentials)
      find('form input[type=submit]').click
    end

    # New users that didn't have an identity should be redirected to the new email page
    expect(current_path).to eq new_my_account_email_path
  end

  scenario "new User signs in using an invitation code with Facebook" do
    Settings.skip_3rd_party_login_account_update = false

    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # Go to the invitation URL and click on 'login_with_facebook' button
    visit invitations_path(code: @invitation_code, redirect_to: new_application_path)
    expect(page).to have_content(@identity.name)
    click_on('login_with_facebook', match: :first)

    # Get the newly created user, he/she should be confirmed and have the corresponding identity
    @user = User.last
    expect(@user).to be_confirmed
    expect(@user.organization_code).to eq(@identity.organization_code)

    # The user should be redirected to the given path
    expect(current_path).to eq(new_application_path)

    # On background: sign-on status token (sst) cookie should be set
    expect(page.driver.request.cookies['_sst'])
      .not_to be_blank

    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "returning User signs in using an invitation code with Facebook" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # An existing user with identity, but not linked with an FB account
    @user = create(:user, :with_identity, email: 'mock_user@facebook.com')
    expect(@user.identities).not_to include(@identity)

    # Go to the invitation URL and click on 'login_with_facebook' button
    visit invitations_path(code: @invitation_code, redirect_to: new_my_account_email_path)
    expect(page).to have_content(@identity.name)
    click_on('login_with_facebook', match: :first)

    # The user should has the corresponding identity
    @user.reload
    expect(@user).to be_confirmed
    expect(@user.identities).to include(@identity)

    # The user should be redirected to the given path
    expect(current_path).to eq(new_my_account_email_path)

    # On background: sign-on status token (sst) cookie should be set
    expect(page.driver.request.cookies['_sst'])
      .not_to be_blank

    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "new User signs up using an invitation code with email" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # Prepare the new user's credentials
    user_rigister_credentials = attributes_for(:user, email: @identity.email).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)

    # Go to the invitation URL and fill the registration form
    visit invitations_path(code: @invitation_code, redirect_to: new_my_account_email_path)
    expect(page).to have_content(@identity.name)
    within ".registration" do
      fill_form_and_submit(:user, user_rigister_credentials)
    end

    # Get the newly created user, he/she should be confirmed and has the corresponding identity
    @user = User.last
    expect(@user).to be_confirmed
    expect(@user.organization_code).to eq(@identity.organization_code)

    # The user should be redirected to the given path
    expect(current_path).to eq(new_my_account_email_path)

    # On background: sign-on status token (sst) cookie should be maintained because the user is automatically signed in
    sst_string = page.driver.request.cookies['_sst']
    sst = SignonStatusTokenService.decode(sst_string)
    expect(sst['id']).to eq(@user.id)
    expect(sst['uuid']).to eq(@user.uuid)
    expect(sst['updated_at']).to eq(@user.updated_at.to_i)

    # On background: identity_token cookie should be maintained because the user is automatically signed in
    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityTokenService.generate(@user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityTokenService.generate(@user)[0..-4]
  end

  scenario "new User signs up using an invitation code with a different email" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # Prepare the new user's credentials
    user_rigister_credentials = attributes_for(:user).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)

    # Go to the invitation URL and fill the registration form
    visit invitations_path(code: @invitation_code, redirect_to: new_my_account_email_path)
    expect(page).to have_content(@identity.name)
    within ".registration" do
      fill_form_and_submit(:user, user_rigister_credentials)
    end

    # Get the newly created user, he/she should not be confirmed and has the corresponding identity
    @user = User.last
    expect(@user).not_to be_confirmed
    expect(@user.organization_code).to eq(@identity.organization_code)

    # Finds his/her account confirmation_path from his/her email inbox
    confirmation_path = open_last_email.body.match(/confirmation\?confirmation_token=[^"]+/)

    # Visiting the confirmation path should confirm the account
    expect do
      visit "/#{confirmation_path}"
      @user.reload
    end.to change { @user.confirmed? }.from(false).to(true)
  end

  scenario "old User signs in using an invitation code with email" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)
    user_rigister_credentials = attributes_for(:user).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)
    @user = create(:user, user_rigister_credentials)
    @user.confirm!

    # The created user can sign in
    login_as @user
    visit(refresh_sst_path)
    expect(page.driver.request.cookies['_sst']).not_to be_blank
    visit(refresh_it_path)
    expect(page.driver.request.cookies['_identity_token']).not_to be_blank

    # Go to the invitation URL and login (again. users should be signed out after clicking the invitation link)
    visit invitations_path(code: @invitation_code, redirect_to: new_my_account_email_path)
    expect(page).to have_content(@identity.name)
    expect(page.driver.request.cookies['_sst']).to be_blank
    expect(page.driver.request.cookies['_identity_token']).to be_blank
    within ".login" do
      fill_form(:user, user_login_credentials)
      find('form input[type=submit]').click
    end

    # The user should have the corresponding identity
    @user.reload
    expect(@user.identities).to include(@identity)

    # The user should be redirected to the given path
    expect(current_path).to eq(new_my_account_email_path)

    expect(page.driver.request.cookies['_sst'])
      .not_to be_blank
    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "User cancels using an invitation code" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    visit invitations_path(code: @invitation_code, redirect_to: new_my_account_email_path)
    expect(page).to have_content(@identity.name)

    visit(invitations_reject_path)
    visit(new_user_session_path)
    expect(page).not_to have_content(@identity.name)
  end
end
