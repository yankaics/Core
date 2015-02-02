class CoreSessionsController < Devise::SessionsController
  after_filter :after_login, only: :create
  after_filter :after_logout, only: [:destroy, :new]

  def create
    # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?

    # redirect new users to verify their email
    if current_user.primary_identity_id.blank? && current_user.created_at > 2.hours.ago
      redirect_to new_my_account_email_path and return
    end

    respond_with resource, location: after_sign_in_path_for(resource)
  end

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

    core_domain = SiteIdentityToken::MaintainService.domain
    redirect_url = params[:redirect_to] || request.env["HTTP_REFERER"]

    if redirect_url && URI.parse(redirect_url).host.ends_with?(core_domain)
      redirect_to redirect_url
    else
      redirect_to root_path
    end
  end
end
