class Users::RegistrationsController < Devise::RegistrationsController
  before_action :random_body_background_image, only: [:edit, :update]

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
          SignonStatusTokenService.update_cookie(cookies, current_user)
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

  def edit
    @new = true if params[:new].present?
    super
  end

  def update
    @new = true if params[:new].present?

    if @new && params[:user]
      params[:user][:current_password] ||= session['user.new_password']
    end

    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      session['user.new_password'] = nil
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, bypass: true

      if @new
        # redirect new users to verify their identity
        if @user.primary_identity_id.blank? &&
           @user.created_at > 2.hours.ago &&
           ENV['SKIP_NEW_USER_IDENTITY_VERIFICATION'] != 'true'
          redirect_to new_my_account_email_path and return
        else
          redirect_to root_path and return
        end
      end

      respond_with resource, location: after_update_path_for(resource)
    else
      flash[:alert] = resource.errors.map { |k, v| "#{k}: #{v}" }.join(', ')
      clean_up_passwords resource
      respond_with resource
    end
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
