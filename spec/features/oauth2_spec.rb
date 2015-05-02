require 'rails_helper'
Dir[File.expand_path('../oauth2/**/*.rb', __FILE__)].each { |f| require f }

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
    include_examples "Authorization Code Grant Flow"

    # RFC 6749 OAuth 2.0 - Implicit Grant
    # https://tools.ietf.org/html/rfc6749#section-4.2
    include_examples "Implicit Grant Flow"

    # RFC 6749 OAuth 2.0 - Resource Owner Password Credentials Grant
    # https://tools.ietf.org/html/rfc6749#section-4.3
    include_examples "Resource Owner Password Credentials Grant Flow"

    # RFC 6749 OAuth 2.0 - Client Credentials Grant
    # https://tools.ietf.org/html/rfc6749#section-4.4
    include_examples "Client Credentials Grant Flow"
  end
end
