class OAuth::AuthorizationsController < Doorkeeper::AuthorizationsController
  after_action :refresh_signon_status_token, only: [:new, :create]

  private

  def refresh_signon_status_token
    SignonStatusTokenService.update_cookie(cookies, current_user)
  end
end
