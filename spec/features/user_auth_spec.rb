require 'rails_helper'

feature "User Auth", :type => :feature do
  before do
    stub_request(:get, "https://graph.facebook.com/me?access_token=mock_token&fields=id,name,link,picture.height(500).width(500),cover,devices,friends&locale=zh-TW")
      .to_return(:status => 200, :body => (<<-eod
{
   "id": "87654321",
   "name": "Facebook User",
   "link": "https://www.facebook.com/app_scoped_user_id/87654321/",
   "picture": {
      "data": {
         "height": 720,
         "is_silhouette": false,
         "url": "http://placehold.it/500x500",
         "width": 720
      }
   },
   "cover": {
      "id": "87654321",
      "offset_y": 55,
      "source": "http://placehold.it/1280x600"
   },
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
         "next": "https://graph.facebook.com/friends_get_next_page"
      },
      "summary": {
         "total_count": 52
      }
   }
}
eod
      ), :headers => {})
    stub_request(:get, "https://graph.facebook.com/friends_get_next_page")
      .to_return(:status => 200, :body => (<<-eod
{
   "data": [
     {
        "name": "Facebook User4",
        "id": "12344321"
     },
     {
        "name": "Facebook User5",
        "id": "23455432"
     }
   ],
   "paging": {
      "previous": ""
   },
   "summary": {
      "total_count": 52
   }
}
eod
      ), :headers => {})
  end

  scenario "new User signs in with Facebook" do
    # Go to the login page and click on 'Sign in with Facebook' button
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)

    # Get the newly created user, he/she should be confirmed
    user = User.last
    expect(user).to be_confirmed

    # Users should be redirected to the new email page after their first login
    expect(current_path).to eq new_my_account_email_path

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

    # On background: identity_token cookie should be cleared
    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank
  end

  scenario "returning User signs in with Facebook" do
    # An existing user with identity, but not linked with an FB account
    user = create(:user, :with_identity, email: 'mock_user@facebook.com')

    # Go to the login page and click on 'Sign in with Facebook' button
    # this should login the user with that corresponding email,
    # and links the user with his/her FB account
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)
    user.reload
    expect(user.fbid).to eq '87654321'

    # expect(page).to ...
    # Old users should not be redirected to the new email page after login
    expect(current_path).not_to eq new_my_account_email_path

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

    # On background: identity_token cookie should be maintained...
    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityTokenService.generate(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityTokenService.generate(user)[0..-4]

    visit('/logout')

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
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # Go to the invitation URL and click on 'Sign in with Facebook' button
    visit invitations_path(code: @invitation_code, redirect_to: '/my_account/emails')
    expect(page).to have_content(@identity.name)
    click_on('Sign in with Facebook', match: :first)

    # Get the newly created user, he/she should be confirmed and have the corresponding identity
    @user = User.last
    expect(@user).to be_confirmed
    expect(@user.organization_code).to eq(@identity.organization_code)

    # The user should be redirected to the given path
    expect(current_path).to eq('/my_account/emails')

    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "returning User signs in using an invitation code with Facebook" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # An existing user with identity, but not linked with an FB account
    @user = create(:user, :with_identity, email: 'mock_user@facebook.com')
    expect(@user.identities).not_to include(@identity)

    # Go to the invitation URL and click on 'Sign in with Facebook' button
    visit invitations_path(code: @invitation_code, redirect_to: '/my_account/emails')
    expect(page).to have_content(@identity.name)
    click_on('Sign in with Facebook', match: :first)

    # The user should has the corresponding identity
    @user.reload
    expect(@user).to be_confirmed
    expect(@user.identities).to include(@identity)

    # The user should be redirected to the given path
    expect(current_path).to eq('/my_account/emails')

    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "new User signs up using an invitation code with email" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    # Prepare the new user's credentials
    user_rigister_credentials = attributes_for(:user).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)

    # Go to the invitation URL and fill the registration form
    visit invitations_path(code: @invitation_code, redirect_to: '/my_account/emails')
    expect(page).to have_content(@identity.name)
    within ".registration" do
      fill_form_and_submit(:user, user_rigister_credentials)
    end

    # Get the newly created user, he/she should be confirmed and has the corresponding identity
    @user = User.last
    expect(@user).to be_confirmed
    expect(@user.organization_code).to eq(@identity.organization_code)

    # The user should be redirected to the given path
    expect(current_path).to eq('/my_account/emails')

    # On background: identity_token cookie should be maintained because the user is automatically signed in
    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityTokenService.generate(@user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityTokenService.generate(@user)[0..-4]
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
    visit(refresh_it_path)
    expect(page.driver.request.cookies['_identity_token']).not_to be_blank

    # Go to the invitation URL and login (again. users should be signed out after clicking the invitation link)
    visit invitations_path(code: @invitation_code, redirect_to: '/my_account/emails')
    expect(page).to have_content(@identity.name)
    expect(page.driver.request.cookies['_identity_token']).to be_blank
    within ".login" do
      fill_form(:user, user_login_credentials)
      find('form input[type=submit]').click
    end

    # The user should have the corresponding identity
    @user.reload
    expect(@user.identities).to include(@identity)

    # The user should be redirected to the given path
    expect(current_path).to eq('/my_account/emails')

    expect(page.driver.request.cookies['_identity_token'])
      .not_to be_blank
  end

  scenario "User cancels using an invitation code" do
    @identity = create(:user_identity)
    @invitation_code = InvitationCodeService.generate(@identity.email)

    visit invitations_path(code: @invitation_code, redirect_to: '/my_account/emails')
    expect(page).to have_content(@identity.name)

    visit(invitations_reject_path)
    visit(new_user_session_path)
    expect(page).not_to have_content(@identity.name)
  end
end
