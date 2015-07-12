# Guard API with OAuth 2.0 Access Token
# Original code from https://github.com/chitsaou/oauth2-api-sample/blob/master/app/api/concerns/api_guard.rb

require 'rack/oauth2'

module APIGuard
  extend ActiveSupport::Concern

  included do |base|
    # OAuth2 Resource Server Authentication
    use Rack::OAuth2::Server::Resource::Bearer, 'The API' do |request|
      request.access_token
    end

    helpers HelperMethods

    install_error_responders(base)
  end

  module HelperMethods
    ##
    # Invokes the doorkeeper guard.
    #
    # If token string is blank, then it raises MissingTokenError.
    #
    # If token is presented and valid, then it sets @current_user.
    #
    # If the token does not have sufficient scopes to cover the requred scopes,
    # then it raises InsufficientTokenScopeError.
    #
    # If the token is expired, then it raises ExpiredTokenError.
    #
    # If the token is revoked, then it raises RevokedTokenError.
    #
    # If the token is not found (nil), then it raises TokenNotFoundError.
    #
    # Arguments:
    #
    #   scopes: (optional) scopes required for this guard.
    #           Defaults to empty array.
    #
    def guard!(scopes: [])
      token_string = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      fail OAuth::MissingTokenError if token_string.blank?
      fail OAuth::TokenNotFoundError if (@access_token ||= find_access_token(token_string)).nil?

      if current_application.present? && current_application.core_app?
        @access_token.scopes = all_scopes.join(' ')
        @scopes = all_scopes
      end

      OAuth::AccessTokenValidationService.validate!(@access_token, scopes: scopes)

      @current_resource_owner = User.find_by(id: @access_token.resource_owner_id)
      @current_user = @current_resource_owner
    end

    def current_access_token
      return @access_token if @access_token
      token_string = request.env[Rack::OAuth2::Server::Resource::ACCESS_TOKEN]
      if token_string.blank?
        @access_token = nil
      else
        @access_token = find_access_token(token_string)
      end
    end

    def current_resource_owner
      @current_resource_owner ||= User.find_by(id: current_access_token.try(:resource_owner_id))
    end

    def current_application
      current_access_token.try(:application)
    end

    alias_method :current_app, :current_application

    def scopes
      @scopes ||= @access_token.scopes.map(&:to_sym)
    end

    def current_user
      @current_user ||= current_resource_owner
    end

    def all_scopes
      if @all_scopes
        @all_scopes
      else
        @all_scopes = Doorkeeper.configuration.default_scopes.instance_variable_get('@scopes') + Doorkeeper.configuration.optional_scopes.instance_variable_get('@scopes')
        @all_scopes = @all_scopes.map(&:to_sym)
      end
    end

    private

    def find_access_token(token_string)
      Doorkeeper::AccessToken.by_token(token_string)
    end
  end

  module ClassMethods
    ##
    # Installs the doorkeeper guard on the whole Grape API endpoint.
    #
    # Arguments:
    #
    #   scopes: (optional) scopes required for this guard.
    #           Defaults to empty array.
    #
    def guard_all!(scopes: [])
      before do
        guard! scopes: scopes
      end
    end

    private

    def install_error_responders(base)
      base.send :rescue_from, OAuth::OAuthError, oauth2_bearer_token_error_handler
    end

    def oauth2_bearer_token_error_handler
      proc do |e|
        response = (
          case e
          when OAuth::MissingTokenError
            Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new

          when OAuth::TokenNotFoundError
            Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(
              :invalid_token,
              "Bad credentials.")

          when OAuth::ExpiredTokenError
            Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(
              :invalid_token,
              "Token has expired.")

          when OAuth::RevokedTokenError
            Rack::OAuth2::Server::Resource::Bearer::Unauthorized.new(
              :invalid_token,
              "Token has been revoked.")

          when OAuth::InsufficientTokenScopeError
            # FIXME: ForbiddenError (inherited from Bearer::Forbidden of Rack::Oauth2)
            # does not include WWW-Authenticate header, which breaks the standard.
            Rack::OAuth2::Server::Resource::Bearer::Forbidden.new(
              :insufficient_scope,
              "The request requires higher privileges than provided by the access token.",
              scope: e.scopes)
          end
        )

        response.finish
      end
    end
  end

  def self.access_token_error_codes
    [
      [401, "Unauthorized: missing or bad access token."],
      [403, "Forbidden: the access token you hand over doesn't give the power you requested."]
    ]
  end

  def self.access_token_required_note(scope: nil)
    if scope.present?
      "An access token with the #{scope} scope is required while making this request."
    else
      "An access token is required while making this request."
    end
  end
end
