class Users::SessionsController < Devise::SessionsController
  after_filter :refresh_site_identity_token, only: [:destroy, :new, :create]
  attr_accessor :can_redirect, :redirect_url, :redirect_url_query, :redirect_url_uri

  def new
    if session[:invitation_code].present?
      invited_guest_email = InvitationCodeService.verify(session[:invitation_code])
      @invited_guest_identity = UserIdentity.unlinked.find_by(email: invited_guest_email)
      if @invited_guest_identity.present?
        @invited_guest_identity.name = @invited_guest_identity.email if @invited_guest_identity.name.blank?
      end
    end

    super
  end

  # Sign in
  def create
    # https://github.com/plataformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?

    # if an invitation_code exists, activate the email for that user
    if session[:invitation_code].present?
      InvitationCodeService.invite(current_user, session[:invitation_code])
      redirect_url = session[:invitation_redirect_url] || root_path

      session[:invitation_code] = nil
      session[:invitation_redirect_url] = nil

      redirect_to redirect_url and return
    end

    # redirect new users to verify their email
    if current_user.primary_identity_id.blank? && current_user.created_at > 2.hours.ago
      redirect_to new_my_account_email_path and return
    end

    respond_with resource, location: after_sign_in_path_for(resource)
  end

  # Sign out
  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?

    check_redirect_to

    if can_redirect
      redirect_to redirect_url
    else
      respond_to_on_destroy
    end
  end

  # Refresh the identity_token
  def refresh_it
    refresh_site_identity_token

    check_redirect_to

    if can_redirect
      redirect_to redirect_url
    else
      redirect_to root_path
    end
  end

  private

  def check_redirect_to
    core_domain = SiteIdentityTokenService.domain
    self.redirect_url = params[:redirect_to] || request.env["HTTP_REFERER"]

    return unless redirect_url

    self.redirect_url_uri = URI.parse(redirect_url)
    self.redirect_url_query = redirect_url_uri.query ? URI.decode_www_form(redirect_url_uri.query) : []
    self.redirect_url_query = redirect_url_query << ['flash[notice]', flash[:notice]]
    self.redirect_url_query = redirect_url_query << ['flash[alert]', flash[:alert]]
    self.redirect_url_uri.query = URI.encode_www_form(redirect_url_query)
    self.redirect_url = redirect_url_uri.to_s

    self.can_redirect = redirect_url && redirect_url_uri.host.ends_with?(core_domain)
  end
end
