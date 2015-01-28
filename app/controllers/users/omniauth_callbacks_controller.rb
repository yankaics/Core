class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    @user = User.from_facebook(request.env["omniauth.auth"])

    # if @user...
      SiteIdentityToken::MaintainService.create_cookie_token(cookies, @user)
      sign_in_and_redirect @user, event: :authentication
    # else
    # end
  end
end
