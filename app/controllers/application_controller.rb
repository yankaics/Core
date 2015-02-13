class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def refresh_site_identity_token
    if current_user
      SiteIdentityTokenService.create(cookies, current_user)
    else
      SiteIdentityTokenService.destroy(cookies)
    end
  end
end
