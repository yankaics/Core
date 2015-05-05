# Sign-on Status Tokens (SST) are credentials used for this SSO systen to verify
# if a specific user is currently signed-in to our service, in a form of
# JSON Web Token (JWT) signed by the core RSA private key that contains data
# about the current user. It will also be stored in the '_sst' cookie shared
# across all subdomains for other services to access.
#
# About JSON Web Token (JWT):
# https://tools.ietf.org/html/draft-ietf-oauth-json-web-token
module SignonStatusTokenService
  class << self
    # Write the sign-on status token to cookie
    def write_to_cookie(cookies, user = current_user)
      set_sst_cookie(cookies, generate(user))
    end

    # Wipe out the sign-on status token from cookie
    def wipe_from_cookie(cookies)
      set_sst_cookie(cookies, '')
    end

    # Update out the sign-on status token in cookie
    def update_cookie(cookies, user = current_user)
      if user
        write_to_cookie(cookies, user)
      else
        wipe_from_cookie(cookies)
      end
    end

    # Generate an sign-on status token for a specific user
    def generate(user)
      return nil if user.blank?
      token_data = {
        iat: Time.now.to_i,
        exp: 5.days.from_now.to_i,
        nbf: 3.seconds.ago.to_i,
        id: user.id,
        uuid: user.uuid,
        updated_at: user.updated_at.to_i
      }
      JWT.encode(token_data, CoreRSAKeyService.private_key, 'RS256')
    end

    # Decodes a sign-on status token
    def decode(token)
      JWT.decode(token, CoreRSAKeyService.public_key, 'RS256')[0]
    rescue
      nil
    end

    private

    def set_sst_cookie(cookies, value)
      sst = { value: value,
              domain: '.' + domain,
              expires: 1.year.from_now }
      sst.except!(:domain) if Rails.env.test?
      cookies[:_sst] = sst
    end

    def domain
      @domain ||= URI.parse(ENV['APP_URL']).host
    end
  end
end
