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
  end
end
