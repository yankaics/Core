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
        cookies[:_identity_token] = nil
      end

      def generate_token(user)
        Digest::MD5.hexdigest("#{user.id}#{secret_key}")
      end

      def secret_key
        @site_secret ||= Digest::MD5.hexdigest(ENV['SITE_SECRET'])[0..16]
        @site_secret + Date.today.year.to_s + Date.today.strftime("%U")
      end

      def domain
        @domain ||= ENV['APP_URL'].gsub(%r{https?:\/\/}, '').gsub('/', '')
      end
    end
  end
end
