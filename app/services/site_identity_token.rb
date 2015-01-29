module SiteIdentityToken
  module MaintainService
    class << self
      def create_cookie_token(cookies, user = current_user)
        identity_token_cookie = { value: generate_token(user),
                                  domain: '.' + domain,
                                  expires: 1.year.from_now }
        identity_token_cookie.except!(:domain) if Rails.env.test?
        cookies[:_identity_token] = identity_token_cookie
      end

      def destroy_cookie_token(cookies)
        identity_token_cookie = { value: '',
                                  domain: '.' + domain,
                                  expires: 1.year.from_now }
        identity_token_cookie.except!(:domain) if Rails.env.test?
        cookies[:_identity_token] = identity_token_cookie
      end

      def generate_token(user)
        timestamp = Time.now.to_time.to_i
        token_hash = Digest::MD5.hexdigest(user.id.to_s + Digest::MD5.hexdigest(secret_key + timestamp.to_s))
        "#{token_hash}.#{timestamp}"
      end

      def secret_key
        @site_secret ||= Digest::MD5.hexdigest(ENV['SITE_SECRET'])[0..16]
      end

      def domain
        @domain ||= URI.parse(ENV['APP_URL']).host
      end
    end
  end
end
