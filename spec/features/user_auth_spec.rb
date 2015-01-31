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
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)
    user = User.last

    # expect(page).to ...

    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityToken::MaintainService.generate_token(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityToken::MaintainService.generate_token(user)[0..-4]

    visit('/logout')

    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank
  end

  scenario "returning User signs in with Facebook" do
    user = create(:user, email: 'mock_user@facebook.com')
    visit(new_user_session_path)
    click_on('Sign in with Facebook', match: :first)

    # expect(page).to ...

    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityToken::MaintainService.generate_token(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityToken::MaintainService.generate_token(user)[0..-4]

    visit('/logout')

    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank
  end

  scenario "new User signs up with email" do
    user_rigister_credentials = attributes_for(:user).slice(:name, :email, :password, :password_confirmation)
    user_login_credentials = user_rigister_credentials.slice(:email, :password)
    visit(new_user_session_path)
    click_on('Sign up', match: :first)
    fill_form_and_submit(:user, user_rigister_credentials)

    visit(new_user_session_path)
    fill_form(:user, user_login_credentials)
    find('form input[type=submit]').click
    # expect(page).to fail...

    user = User.last
    confirmation_path = open_last_email.body.match /confirmation\?confirmation_token=[^"]+/
    expect do
      visit "/#{confirmation_path}"
      user.reload
    end.to change { user.confirmed? }.from(false).to(true)

    visit(new_user_session_path)
    fill_form(:user, user_login_credentials)
    find('form input[type=submit]').click

    # expect(page).to ...

    if (page.driver.request.cookies['_identity_token'] !=
        SiteIdentityToken::MaintainService.generate_token(user))
      visit('/refresh_it')
    end
    expect(page.driver.request.cookies['_identity_token'][0..-4])
      .to eq SiteIdentityToken::MaintainService.generate_token(user)[0..-4]

    visit('/logout')

    expect(page.driver.request.cookies['_identity_token'])
      .to be_blank
  end
end
