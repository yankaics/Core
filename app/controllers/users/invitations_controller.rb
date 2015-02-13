class Users::InvitationsController < ApplicationController

  def receive
    code = params[:code]
    if InvitationCodeService.verify(code)
      sign_out :user
      SiteIdentityTokenService.update(cookies, current_user)
      session[:invitation_code] = code
      session[:invitation_redirect_url] = params[:redirect_to]
      redirect_to new_user_session_path
    else
      flash[:alert] = "無效的邀請碼！"
      redirect_to root_path
    end
  end

  def reject
    session[:invitation_code] = nil
    redirect_to new_user_session_path
  end
end
