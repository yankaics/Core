class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  after_action :refresh_signon_status_token, only: [:new, :create]
  after_action :refresh_site_identity_token, only: [:new, :create]

  private

  def refresh_signon_status_token
    SignonStatusTokenService.update_cookie(cookies, current_user)
  end

  def refresh_site_identity_token
    SiteIdentityTokenService.update(cookies, current_user)
  end
end
