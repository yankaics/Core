class CoreSessionsController < Devise::SessionsController
  after_filter :after_login, only: :create
  after_filter :after_logout, only: :destroy

  def after_login
    SiteIdentityToken::MaintainService.create_cookie_token(cookies, current_user)
  end

  def after_logout
    SiteIdentityToken::MaintainService.destroy_cookie_token(cookies)
  end

  def refresh_it
    if user_signed_in?
      SiteIdentityToken::MaintainService.create_cookie_token(cookies, current_user)
    else
      SiteIdentityToken::MaintainService.destroy_cookie_token(cookies)
    end
    if request.env["HTTP_REFERER"]
      redirect_to request.env["HTTP_REFERER"]
    else
      redirect_to root_path
    end
  end
end
