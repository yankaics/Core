class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  after_action :refresh_site_identity_token, only: [:new, :create]

  def refresh_site_identity_token
    SiteIdentityTokenService.update(cookies, current_user)
  end
end
