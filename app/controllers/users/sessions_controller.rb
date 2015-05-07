class Users::SessionsController < Devise::SessionsController
  include RedirectCheckingHelper

  after_filter :refresh_signon_status_token, only: [:destroy, :new, :create]
  protect_from_forgery except: :destroy

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
    signed_out = sign_out(:user)
    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
    yield if block_given?

    check_redirect_to

    if can_redirect
      redirect_to redirect_url
    else
      respond_to_on_destroy
    end
  end
end
