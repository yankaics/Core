module OAuth
  # Base class for all OAuth errors. These map to error codes in the spec.
  class OAuthError < StandardError
    def initialize(code, message)
      super message
      @code = code.to_sym
    end
    # The OAuth error code.
    attr_reader :code
  end

  # Access token expired, client cannot refresh and needs new authorization.
  class InvalidTokenError < OAuthError
    def initialize
      super :invalid_token, "The access token is no longer valid."
    end
  end

  # Access token revoked, client cannot refresh and needs new authorization.
  class RevokedTokenError < OAuthError
    def initialize
      super :revoked_token, "The access token has been revoked and is no longer valid."
    end
  end

  # Access token expired, client may refresh and get a new token.
  class ExpiredTokenError < OAuthError
    def initialize
      super :expired_token, "The access token has expired."
    end
  end

  # Access token missing.
  class MissingTokenError < OAuthError
    def initialize
      super :missing_token, "An access token is required."
    end
  end

  # Bad access token.
  class TokenNotFoundError < OAuthError
    def initialize
      super :bad_token, "Bad access token."
    end
  end

  # Request Access token scope insufficient.
  class InsufficientTokenScopeError < OAuthError
    attr_reader :scopes
    def initialize(scopes)
      @scopes = scopes
      super :insufficient_token_scope, "The access token dosen't have the scope of this request."
    end
  end
end
