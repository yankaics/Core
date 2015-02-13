class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_facebook(request.env["omniauth.auth"])

    # if @user...
      SiteIdentityTokenService.create(cookies, @user)

      # redirect new users to verify their email
      if @user.primary_identity_id.blank? && @user.created_at > 2.hours.ago
        sign_in @user
        redirect_to new_my_account_email_path
      else
        sign_in_and_redirect @user, event: :authentication
      end
    # else
    # end
  end
end
