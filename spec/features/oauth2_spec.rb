require 'rails_helper'

feature "OAuth 2.0", :type => :feature do
  before :each do
    @user = create(:user)
    @user.confirm!
    login_as @user
    @app = create(:oauth_application, redirect_uri: "urn:ietf:wg:oauth:2.0:oob\nhttp://non-existing.oauth.testing.app/")
  end

  describe "Obtaining Authorization" do
    # RFC 6749 OAuth 2.0 - Authorization Code Grant
    # https://tools.ietf.org/html/rfc6749#section-4.1
    scenario "Authorization Code Grant" do
      # calling the API without a token should return error
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'

      # Authorization Code Grant
      state = 'awesome'
      redirect_uri = 'http://non-existing.oauth.testing.app/'
      scope = %w(public identity)

      visit(<<-URL.squish.delete(' ')
        /oauth/authorize?
        client_id=#{@app.uid}&
        redirect_uri=#{redirect_uri}&
        response_type=code&
        scope=#{scope.join('%20')}&
        state=#{state}
        URL
      )

      expect(page).to have_content(@app.name)
      first('input[type=submit]').click

      # the grant code is expected to be in the url parameter
      u = URI.parse(current_url)
      q = CGI.parse(u.query)
      expect(q['state'].first).to eq state
      grant_code = q['code'].first

      # client exchanges the access token with grant code
      page.driver.browser.basic_authorize(@app.uid, @app.secret)
      page.driver.post "/oauth/token", grant_type: 'authorization_code',
                                       code: grant_code,
                                       client_id: @app.uid,
                                       redirect_uri: redirect_uri
      response = JSON.parse(page.body)
      expect(response).to have_key 'access_token'
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

      # access token will expire
      Timecop.travel(1.days.from_now)
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'
    end

    # RFC 6749 OAuth 2.0 - Implicit Grant
    # https://tools.ietf.org/html/rfc6749#section-4.2
    scenario "Implicit Grant" do
      # calling the API without a token should return error
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'

      # Implicit Grant
      redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
      scope = %w(public facebook sms)

      visit(<<-URL.squish.delete(' ')
        /oauth/authorize?
        client_id=#{@app.uid}&
        redirect_uri=#{redirect_uri}&
        scope=#{scope.join('%20')}&
        response_type=token&
        URL
      )

      expect(page).to have_content(@app.name)
      first('input[type=submit]').click

      # the access token is expected to be in the url parameter
      u = URI.parse(current_url)
      q = CGI.parse(u.query)
      access_token = q['access_token'].first

      # test if the scope of access token is as expect
      visit "/oauth/token/info?access_token=#{access_token}"
      response = JSON.parse(page.body)
      expect(response['scopes']).to eq scope

      # calling the API with a valid token should return corresponding data
      visit "/api/v1/me?access_token=#{access_token}"
      response = JSON.parse(page.body)
      expect(response['name']).to eq @user.name

      # access token will expire
      Timecop.travel(1.days.from_now)
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'
    end

    scenario "Grant Code expires on Authorization Code Grant" do
      # Authorization Code Grant
      redirect_uri = 'http://non-existing.oauth.testing.app/'

      visit(<<-URL.squish.delete(' ')
        /oauth/authorize?
        client_id=#{@app.uid}&
        redirect_uri=#{redirect_uri}&
        response_type=code
        URL
      )

      expect(page).to have_content(@app.name)
      first('input[type=submit]').click

      # the grant code is expected to be in the url parameter
      u = URI.parse(current_url)
      q = CGI.parse(u.query)
      grant_code = q['code'].first

      # client exchanges the access token with grant code
      # after too long
      Timecop.travel(1.minute.from_now)
      page.driver.browser.basic_authorize(@app.uid, @app.secret)
      page.driver.post "/oauth/token", grant_type: 'authorization_code',
                                       code: grant_code,
                                       client_id: @app.uid,
                                       redirect_uri: redirect_uri
      response = JSON.parse(page.body)
      expect(response).not_to have_key 'access_token'
      expect(response).to have_key 'error'
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
      expect(response).not_to have_key 'devices'

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
      expect(response).to have_key 'devices'

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

    # Resource Owner Facebook Access Token Grant
    scenario "Resource Owner Facebook Access Token Grant" do
      fbtoken = 'facebook_access_token'
      fbtoken_of_other_app = 'facebook_access_token_of_other_app'

      # Stub requests to Facebook
      stub_request(:get, "https://graph.facebook.com/debug_token?access_token=#{fbtoken}&input_token=#{fbtoken}")
        .to_return(body: <<-eos
          {
            "data": {
              "app_id": "#{ENV['FB_APP_ID']}",
              "application": "Colorgy",
              "expires_at": 1000000000,
              "is_valid": true,
              "scopes": [
                "public_profile",
                "basic_info",
                "email",
                "user_friends"
              ],
              "user_id": "1234567890"
            }
          }
        eos
      )
      stub_request(:get, "https://graph.facebook.com/debug_token?access_token=#{fbtoken_of_other_app}&input_token=#{fbtoken_of_other_app}")
        .to_return(body: <<-eos
          {
            "data": {
              "app_id": "some_other_app",
              "application": "Colorgy",
              "expires_at": 1000000000,
              "is_valid": true,
              "scopes": [
                "public_profile"
              ],
              "user_id": "1234567890"
            }
          }
        eos
      )
      stub_request(:get, "https://graph.facebook.com/debug_token?access_token=invalid_token&input_token=invalid_token")
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
      stub_request(:get, "https://graph.facebook.com/me?access_token=#{fbtoken}&fields=id,name,link,picture.height(500).width(500),cover,devices,friends&locale=#{I18n.locale}")
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
        password=#{fbtoken}
        URL
      )

      response = JSON.parse(page.body)
      expect(response).to have_key 'access_token'

      # Fail if access token is owned by other app
      page.driver.post(<<-URL.squish.delete(' ')
        /oauth/token?
        grant_type=password&
        username=facebook:access_token&
        password=#{fbtoken_of_other_app}
        URL
      )

      response = JSON.parse(page.body)
      expect(response).not_to have_key 'access_token'
      expect(response).to have_key 'error'

      # Fail if an invalid access token is provided
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

    # RFC 6749 OAuth 2.0 - Client Credentials Grant
    # https://tools.ietf.org/html/rfc6749#section-4.4
    scenario "Client Credentials Grant" do
      # Client Credentials Grant
      page.driver.post(<<-URL.squish.delete(' ')
        /oauth/token?
        grant_type=client_credentials&
        client_id=#{@app.uid}&
        client_secret=#{@app.secret}
        URL
      )

      response = JSON.parse(page.body)
      expect(response).to have_key 'access_token'
      access_token = response['access_token']

      # test the access token
      visit "/oauth/token/info?access_token=#{access_token}"
      response = JSON.parse(page.body)
      expect(response['application']['uid']).to eq(@app.uid)

      # Client Credentials Grant with HTTP Basic Auth
      page.driver.browser.basic_authorize(@app.uid, @app.secret)
      page.driver.post(<<-URL.squish.delete(' ')
        /oauth/token?
        grant_type=client_credentials
        URL
      )

      response = JSON.parse(page.body)
      expect(response).to have_key 'access_token'
      access_token = response['access_token']

      # test the access token
      visit "/oauth/token/info?access_token=#{access_token}"
      response = JSON.parse(page.body)
      expect(response['application']['uid']).to eq(@app.uid)
    end
  end
end
