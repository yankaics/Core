class Users::RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
    build_resource(sign_up_params)

    ActiveRecord::Base.transaction do
      resource_saved = resource.save
      yield resource if block_given?
      if resource_saved
        if session[:invitation_code].present?
          InvitationCodeService.invite(resource, session[:invitation_code])
          @redirect_url = session[:invitation_redirect_url] || root_path
          session[:invitation_code] = nil
          session[:invitation_redirect_url] = nil
        end
        if resource.confirmed?
          sign_in resource
          SiteIdentityTokenService.update(cookies, current_user)
          redirect_to @redirect_url and return if @redirect_url
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          resource.send_confirmation_instructions
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        @validatable = devise_mapping.validatable?
        if @validatable
          @minimum_password_length = resource_class.password_length.min
        end
        respond_with resource
      end
    end
  end

  def update
    super
  end

  def destroy
    redirect_to root_path
  end

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
