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
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'

      state = 'awesome'
      redirect_uri = 'http://non-existing.oauth.testing.app/'

      visit(<<-URL.squish.delete(' ')
        /oauth/authorize?
        client_id=#{@app.uid}&
        redirect_uri=#{redirect_uri}&
        response_type=code&
        state=#{state}
        URL
      )

      expect(page).to have_content(@app.name)
      first('input[type=submit]').click

      u = URI.parse(current_url)
      q = CGI.parse(u.query)
      expect(q['state'].first).to eq state
      grant_code = q['code'].first

      page.driver.browser.basic_authorize(@app.uid, @app.secret)
      page.driver.post "/oauth/token", grant_type: 'authorization_code',
                                       code: grant_code,
                                       client_id: @app.uid,
                                       redirect_uri: redirect_uri
      response = JSON.parse(page.body)
      expect(response).to have_key 'access_token'
      access_token = response['access_token']

      page.driver.browser.header 'Authorization', "Bearer #{access_token}"

      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response['user']['name']).to eq @user.name
    end

    # RFC 6749 OAuth 2.0 - Implicit Grant
    # https://tools.ietf.org/html/rfc6749#section-4.2
    scenario "Implicit Grant" do
      visit "/api/v1/me"
      response = JSON.parse(page.body)
      expect(response).to have_key 'error'

      redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'

      visit(<<-URL.squish.delete(' ')
        /oauth/authorize?
        client_id=#{@app.uid}&
        redirect_uri=#{redirect_uri}&
        response_type=token&
        URL
      )

      expect(page).to have_content(@app.name)
      first('input[type=submit]').click

      u = URI.parse(current_url)
      q = CGI.parse(u.query)
      access_token = q['access_token'].first

      visit "/api/v1/me?access_token=#{access_token}"
      response = JSON.parse(page.body)
      expect(response['user']['name']).to eq @user.name
    end
  end
end
