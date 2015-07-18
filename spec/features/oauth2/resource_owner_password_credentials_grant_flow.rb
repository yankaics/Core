require 'rails_helper'

RSpec.shared_examples "Resource Owner Password Credentials Grant Flow" do
  before do
    ENV['FB_APP_ADDITIONAL_SCOPES'] = ''
    Settings.fb_app_ids = "whitelisted_app\nsome_whitelisted_app\r\nanother_whitelisted_app"
  end

  # RFC 6749 OAuth 2.0 - Resource Owner Password Credentials Grant
  # https://tools.ietf.org/html/rfc6749#section-4.3
  scenario "Resource Owner Password Credentials Grant" do
    # Resource Owner Password Credentials Grant, POST to the endpoint to get a token
    scope = %w(public facebook sms)

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.email}&
      password=#{@user.password}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).not_to have_key 'refresh_token'
    access_token = response['access_token']

    # test if the scope of access token is as expect
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['scopes']).to eq scope

    # calling the API with a valid token should return corresponding data
    page.driver.browser.header 'Authorization', "Bearer #{access_token}"
    visit "/api/v1/me"
    response = JSON.parse(page.body)
    expect(response['name']).to eq @user.name
    expect(response).not_to have_key 'fb_devices'

    # This grant flow also accept using username
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.username}&
      password=#{@user.password}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).not_to have_key 'refresh_token'

    # This grant flow will fail if wrong credentials are provided
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.username}&
      password=wrong_password
      URL
    )

    response = JSON.parse(page.body)
    expect(response).not_to have_key 'access_token'
    expect(response).to have_key 'error'

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=wrong_username&
      password=#{@user.password}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).not_to have_key 'access_token'
    expect(response).to have_key 'error'

    # Resource Owner Password Credentials Grant with Core App powers
    @core_app = create(:oauth_application, :owned_by_admin, redirect_uri: "urn:ietf:wg:oauth:2.0:oob\nhttp://non-existing.oauth.testing.app/")

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      client_id=#{@core_app.uid}&
      client_secret=#{@core_app.secret}&
      username=#{@user.email}&
      password=#{@user.password}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    access_token = response['access_token']

    # calling the API with a valid token should return corresponding data
    page.driver.browser.header 'Authorization', "Bearer #{access_token}"
    visit "/api/v1/me"
    response = JSON.parse(page.body)
    expect(response).to have_key 'fb_devices'

    # The user's access will be locked if having too many failed attempts
    15.times do
      page.driver.post(<<-URL.squish.delete(' ')
        /oauth/token?
        grant_type=password&
        username=#{@user.username}&
        password=wrong_password
        URL
      )
    end

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.username}&
      password=#{@user.password}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).not_to have_key 'access_token'
    expect(response).to have_key 'error'

    # the locked user will be unlocked automatically after a period of time
    Timecop.travel(3.hours.from_now)

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.username}&
      password=#{@user.password}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).not_to have_key 'error'

    Timecop.return
  end

  scenario "Resource Owner Password Credentials Grant with Refresh Token (offline_access)" do
    # An refresh token will be issued if the client is not verified
    scope = %w(public offline_access long_term)

    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=#{@user.email}&
      password=#{@user.password}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).to have_key 'refresh_token'
    expect(response['scope']).to include('offline_access')

    # An refresh token will be issued if the client is verified
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      client_id=#{@app.uid}&
      client_secret=#{@app.secret}&
      username=#{@user.email}&
      password=#{@user.password}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).to have_key 'refresh_token'
    access_token = response['access_token']
    refresh_token = response['refresh_token']
    expect(response['scope']).to include('offline_access')

    # client requests for a new access token with the refresh token
    page.driver.post "/oauth/token", grant_type: 'refresh_token',
                                     refresh_token: refresh_token
    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).to have_key 'refresh_token'
    access_token = response['access_token']
    refresh_token = response['refresh_token']
  end

  # Resource Owner Facebook Access Token Credentials Grant
  scenario "Resource Owner Facebook Access Token Credentials Grant" do
    fbtoken = 'facebook_access_token'
    fbtoken_of_other_app = 'facebook_access_token_of_other_app'
    fbtoken_of_whitelisted_app = 'facebook_access_token_of_whitelisted_app'
    scope = %w(public email)
    @core_app = create(:oauth_application, :owned_by_admin, redirect_uri: "urn:ietf:wg:oauth:2.0:oob\nhttp://non-existing.oauth.testing.app/")

    # Stub requests to Facebook
    stub_request(:get, "https://graph.facebook.com/app?access_token=#{fbtoken}")
      .to_return(body: <<-eos
        {
          "id": "#{ENV['FB_APP_ID']}"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/app?access_token=#{fbtoken_of_other_app}")
      .to_return(body: <<-eos
        {
          "id": "some_other_app"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/app?access_token=#{fbtoken_of_whitelisted_app}")
      .to_return(body: <<-eos
        {
          "id": "some_whitelisted_app"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/app?access_token=invalid_token")
      .to_return(body: <<-eos
        {
          "error": {
            "message": "Invalid OAuth access token.",
            "type": "OAuthException",
            "code": 190
          }
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/me?access_token=invalid_token&fields=id,name,email,gender")
      .to_return(body: <<-eos
        {
          "error": {
            "message": "Invalid OAuth access token.",
            "type": "OAuthException",
            "code": 190
          }
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/me?access_token=#{fbtoken}&fields=id,name,email,gender")
      .to_return(body: <<-eos
        {
          "id": "1234567890",
          "name": "Facebook User",
          "email": "user@facebook.com",
          "gender": "male"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/me?access_token=#{fbtoken_of_other_app}&fields=id,name,email,gender")
      .to_return(body: <<-eos
        {
          "id": "0987654321",
          "name": "Facebook User",
          "email": "user@facebook.com",
          "gender": "male"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/me?access_token=#{fbtoken_of_whitelisted_app}&fields=id,name,email,gender")
      .to_return(body: <<-eos
        {
          "id": "0987654321",
          "name": "Facebook User",
          "email": "user@facebook.com",
          "gender": "male"
        }
      eos
    )
    stub_request(:get, "https://graph.facebook.com/me?access_token=#{fbtoken}&fields=id,email,name,picture.height(500).width(500),cover,gender,link,devices&locale=#{I18n.locale}")
      .to_return(body: <<-eos
        {
          "id": "1234567890",
          "name": "Facebook User",
          "link": "https://www.facebook.com/app_scoped_user_id/1234567890/",
          "picture": {
            "data": {
              "height": 720,
              "is_silhouette": false,
              "url": "",
              "width": 720
            }
          },
          "cover": {
            "id": "0",
            "offset_y": 0,
            "source": ""
          },
          "devices": [],
          "friends": {
            "data": [],
            "summary": {
              "total_count": 0
            }
          }
        }
      eos
    )

    # Resource Owner Facebook Access Token Grant, POST to the endpoint to get a token
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=facebook:access_token&
      password=#{fbtoken}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    access_token = response['access_token']
    user = Doorkeeper::AccessToken.find_by(token: access_token).resource_owner

    # check the token
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['scopes']).to eq(scope)

    visit "/api/v1/me.json?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response).to have_key('email')

    # If the provided Facebook access token is owned by other app
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      client_id=#{@core_app.uid}&
      client_secret=#{@core_app.secret}&
      username=facebook:access_token&
      password=#{fbtoken_of_other_app}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).not_to have_key 'error'
    access_token = response['access_token']
    user2 = Doorkeeper::AccessToken.find_by(token: access_token).resource_owner

    expect(user2).to eq(user)

    # check the token
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['scopes']).to contain_exactly('public')

    visit "/api/v1/me.json?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response).not_to have_key('email')

    # If the provided Facebook access token is owned by a white-listed app
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      client_id=#{@core_app.uid}&
      client_secret=#{@core_app.secret}&
      username=facebook:access_token&
      password=#{fbtoken_of_whitelisted_app}&
      scope=#{scope.join('%20')}
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    expect(response).not_to have_key 'error'
    access_token = response['access_token']
    user2 = Doorkeeper::AccessToken.find_by(token: access_token).resource_owner

    expect(user2).to eq(user)

    # check the token
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['scopes']).to eq(scope)

    visit "/api/v1/me.json?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response).to have_key('email')

    # Fail if an invalid Facebook access token is provided
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=password&
      username=facebook:access_token&
      password=invalid_token
      URL
    )

    response = JSON.parse(page.body)
    expect(response).not_to have_key 'access_token'
    expect(response).to have_key 'error'
  end
end
