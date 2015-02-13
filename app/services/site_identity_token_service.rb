module SiteIdentityTokenService
  class << self
    def create(cookies, user = current_user)
      set_identity_token_cookie(cookies, generate(user))
    end

    def destroy(cookies)
      set_identity_token_cookie(cookies, '')
    end

    def update(cookies, user = current_user)
      if user
        create(cookies, user)
      else
        destroy(cookies)
      end
    end

    def generate(user)
      timestamp = Time.now.to_time.to_i
      token_hash = Digest::MD5.hexdigest(user.id.to_s + Digest::MD5.hexdigest(secret_key + timestamp.to_s))
      user_updated_at = user.updated_at.to_time.to_i
      "#{token_hash}.#{timestamp}.#{user_updated_at}"
    end

    def set_identity_token_cookie(cookies, value)
      identity_token_cookie = { value: value,
                                domain: '.' + domain,
                                expires: 1.year.from_now }
      identity_token_cookie.except!(:domain) if Rails.env.test?
      cookies[:_identity_token] = identity_token_cookie
    end

    def secret_key
      @site_secret ||= Digest::MD5.hexdigest(ENV['SITE_SECRET'])[0..16]
    end

    def domain
      @domain ||= URI.parse(ENV['APP_URL']).host
    end
  end
end
