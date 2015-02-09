class Admin::TestingUserSessionsController < ApplicationController
  before_action :authenticate_admin!

  def create
    return unless current_admin.root?
    @user = User.find(params[:id])
    logger.info "Admin #{current_admin.id} is logging in as user #{@user.id}"
    SiteIdentityToken::MaintainService.create_cookie_token(cookies, @user) if @user.confirmed?
    sign_in_and_redirect @user, event: :authentication
  end
end
