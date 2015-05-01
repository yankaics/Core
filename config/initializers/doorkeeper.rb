Doorkeeper.configure do
  # Change the ORM that doorkeeper will use.
  # Currently supported options are :active_record, :mongoid2, :mongoid3,
  # :mongoid4, :mongo_mapper
  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    # Put your resource owner authentication logic here.
    # Example implementation:
    #   User.find_by_id(session[:user_id]) || redirect_to(new_user_session_url)
    current_user || warden.authenticate!(:scope => :user)
  end

  # If you want to restrict access to the web interface for adding oauth authorized applications, you need to declare the block below.
  admin_authenticator do
    # Put your admin authentication logic here.
    # Example implementation:
    # Admin.find_by_id(session[:admin_id]) || redirect_to(new_admin_session_url)
    current_user
  end

  # Authorization Code expiration time (default 10 minutes).
  authorization_code_expires_in 30.seconds

  # Access token expiration time (default 2 hours).
  # If you want to disable expiration, set this to nil.
  access_token_expires_in 2.hours

  # Reuse access token for the same resource owner within an application (disabled by default)
  # Rationale: https://github.com/doorkeeper-gem/doorkeeper/issues/383
  # reuse_access_token

  # Issue access tokens with refresh token (disabled by default)
  use_refresh_token

  # Provide support for an owner to be assigned to each registered application (disabled by default)
  # Optional parameter :confirmation => true (default false) if you want to enforce ownership of
  # a registered application
  # Note: you must also run the rails g doorkeeper:application_owner generator to provide the necessary support
  enable_application_owner :confirmation => true

  # Define access token scopes for your provider
  # For more information go to
  # https://github.com/doorkeeper-gem/doorkeeper/wiki/Using-Scopes
  default_scopes  :public
  optional_scopes :email, :account, :identity, :facebook, :info,
                  :notifications, :send_notification, :sms, :offline_access

  # Change the way client credentials are retrieved from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:client_id` and `:client_secret` params from the `params` object.
  # Check out the wiki for more information on customization
  # client_credentials :from_basic, :from_params

  # Change the way access token is authenticated from the request object.
  # By default it retrieves first from the `HTTP_AUTHORIZATION` header, then
  # falls back to the `:access_token` or `:bearer_token` params from the `params` object.
  # Check out the wiki for more information on customization
  # access_token_methods :from_bearer_authorization, :from_access_token_param, :from_bearer_param

  # Change the native redirect uri for client apps
  # When clients register with the following redirect uri, they won't be redirected to any server and the authorization code will be displayed within the provider
  # The value can be any string. Use nil to disable this feature. When disabled, clients must provide a valid URL
  # (Similar behaviour: https://developers.google.com/accounts/docs/OAuth2InstalledApp#choosingredirecturi)
  #
  # native_redirect_uri 'urn:ietf:wg:oauth:2.0:oob'

  # Forces the usage of the HTTPS protocol in non-native redirect uris (enabled
  # by default in non-development environments). OAuth2 delegates security in
  # communication to the HTTPS protocol so it is wise to keep this enabled.
  #
  force_ssl_in_redirect_uri false

  # Specify what grant flows are enabled in array of Strings. The valid
  # strings and the flows they enable are:
  #
  # "authorization_code" => Authorization Code Grant Flow
  # "implicit"           => Implicit Grant Flow
  # "password"           => Resource Owner Password Credentials Grant Flow
  # "client_credentials" => Client Credentials Grant Flow
  #
  # If not specified, Doorkeeper enables authorization_code and
  # client_credentials.
  #
  # implicit and password grant flows have risks that you should understand
  # before enabling:
  #   http://tools.ietf.org/html/rfc6819#section-4.4.2
  #   http://tools.ietf.org/html/rfc6819#section-4.4.3
  #
  grant_flows %w(authorization_code client_credentials implicit password)

  resource_owner_from_credentials do |routes|
    case params[:username]
    when 'facebook:access_token'
      debug_token_connection = HTTParty.get(
        <<-eos.squish.delete(' ')
          https://graph.facebook.com/debug_token?
            input_token=#{params[:password]}&
            access_token=#{params[:password]}
          eos
      )

      token_info = debug_token_connection.parsed_response
      token_info = JSON.parse(token_info) if token_info.is_a?(String)

      if token_info['data'].is_a?(Hash)
        get_access_connection = HTTParty.get(
          <<-eos.squish.delete(' ')
            https://graph.facebook.com/me?
              fields=id,name,email,gender&
              access_token=#{params[:password]}
            eos
        )

        access = get_access_connection.parsed_response
        access = JSON.parse(access) if access.is_a?(String)

        if access['id'].present?
          # the access token is owned by this app, provide full information
          if token_info['data']['app_id'] == ENV['FB_APP_ID']
            facebook_auth = {
              uid: access['id'],
              credentials: {
                token: params[:password]
              },
              info: {
                email: access['email'],
                name: access['name']
              },
              extra: {
                raw_info: {
                  gender: access['gender']
                }
              }
            }
          # the access token is not owned by this app, provide limited information
          else
            facebook_auth = {
              credentials: {
                token: params[:password]
              },
              info: {
                email: access['email'],
                name: access['name']
              },
              extra: {
                raw_info: {
                  gender: access['gender']
                }
              }
            }
          end

          u = User.from_facebook(facebook_auth)
          u
        else
          nil
        end
      else
        nil
      end

    else
      u = User.find_for_database_authentication(email: params[:username])
      u = User.find_for_database_authentication(username: params[:username]) if u.blank?

      if u.present?
        if u.access_locked?
          u.unlock_access! if u.locked_at < Time.now - User.unlock_in
        end

        if u.access_locked?
          nil
        elsif u.valid_password?(params[:password])
          u.failed_attempts = 0 && u.save! if u.failed_attempts > 0
          u
        else
          u.failed_attempts += 1
          u.save!
          u.lock_access! if u.failed_attempts > User.maximum_attempts
          nil
        end
      end
    end
  end

  # Under some circumstances you might want to have applications auto-approved,
  # so that the user skips the authorization step.
  # For example if dealing with trusted a application.
  skip_authorization do |resource_owner, client|
    client.application.core_app?
  end

  # WWW-Authenticate Realm (default "Doorkeeper").
  realm ENV['APP_NAME']
end

Doorkeeper.configuration.token_grant_types << "password"

module OAuthApplication
  extend ActiveSupport::Concern

  included do
    scope :user_apps, -> { where("owner_type = ?", 'User') }
    scope :core_apps, -> { where("owner_type = ?", 'Admin') }

    before_create :set_initial_refresh_time
  end

  module ClassMethods
  end

  def core_app?
    owner_type == 'Admin'
  end

  def regenerate_secret!
    self.secret = nil
    send :generate_secret
    save!
  end

  private

  def set_initial_refresh_time
    self.rth_refreshed_at = DateTime.now.change(min: 0, sec: 0)
    self.rtd_refreshed_at = Date.today
    self.core_rth_refreshed_at = DateTime.now.change(min: 0, sec: 0)
    self.core_rtd_refreshed_at = Date.today
  end
end

Doorkeeper::Application.send :include, OAuthApplication

module OAuthAccessToken
  extend ActiveSupport::Concern

  included do
    belongs_to :resource_owner, class_name: :User
  end

  # Override the use_refresh_token? method to issue refresh token only if the scope contains 'offline_access'
  def use_refresh_token?
    !!@use_refresh_token && scopes.include?('offline_access') && application_id.present?
  end
end

Doorkeeper::AccessToken.send :include, OAuthAccessToken
