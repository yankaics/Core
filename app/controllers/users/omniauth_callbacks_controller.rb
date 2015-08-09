class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_facebook(request.env["omniauth.auth"])

    if @user.present? && @user.valid?
      SignonStatusTokenService.write_to_cookie(cookies, @user)
      SiteIdentityTokenService.create(cookies, @user)

      # if an invitation_code exists, activate the email for that user
      if session[:invitation_code].present?
        InvitationCodeService.invite(resource, session[:invitation_code])
        @redirect_url = session[:invitation_redirect_url] || root_path
        session[:invitation_code] = nil
        session[:invitation_redirect_url] = nil
        sign_in @user
        redirect_to @redirect_url and return if @redirect_url
      end

      # redirect new users to update their identity
      if @user.created_at > 1.minute.ago &&
         ENV['SKIP_3RD_PARTY_LOGIN_ACCOUNT_UPDATE'] != 'true'
        session['user.new_password'] = @user.new_password
        sign_in @user
        redirect_to edit_user_registration_path(new: 'go')

      # redirect new users to verify their identity
      elsif @user.primary_identity_id.blank? &&
            @user.created_at > 2.hours.ago &&
            ENV['SKIP_NEW_USER_IDENTITY_VERIFICATION'] != 'true'
        sign_in @user
        redirect_to new_my_account_email_path

      else
        sign_in_and_redirect @user, event: :authentication
      end
    else
      flash[:alert] = "錯誤：請確認您的 Facebook 帳號是有效的 (啟用並已驗證信箱)，或嘗試其他登入方式！"
      redirect_to new_user_session_path
    end
  end
end
