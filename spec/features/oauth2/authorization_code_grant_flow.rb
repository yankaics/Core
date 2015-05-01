require 'rails_helper'

RSpec.shared_examples "Authorization Code Grant Flow" do
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
end
