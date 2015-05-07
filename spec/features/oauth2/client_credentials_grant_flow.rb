require 'rails_helper'

RSpec.shared_examples "Client Credentials Grant Flow" do
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
    expect(response).not_to have_key 'refresh_token'
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
    expect(response).not_to have_key 'refresh_token'
    access_token = response['access_token']

    # test the access token
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['application']['uid']).to eq(@app.uid)
  end

  scenario "Client Credentials Grant with long-term access (long_term)" do
    # Client Credentials Grant with the long_term scope
    page.driver.post(<<-URL.squish.delete(' ')
      /oauth/token?
      grant_type=client_credentials&
      client_id=#{@app.uid}&
      client_secret=#{@app.secret}&
      scope=long_term
      URL
    )

    response = JSON.parse(page.body)
    expect(response).to have_key 'access_token'
    access_token = response['access_token']
    expect(response['expires_in']).to be > 1.year.to_i

    # test the access token
    visit "/oauth/token/info?access_token=#{access_token}"
    response = JSON.parse(page.body)
    expect(response['application']['uid']).to eq(@app.uid)
    expect(response['scopes']).to include('long_term')
    expect(response['expires_in_seconds']).to be > 1.year.to_i
  end
end
