class Users::MyAccountController < ApplicationController
  before_action :authenticate_user!
  decorates_assigned :user

  def show
    @user = current_user.clone
    @body_background_image = current_user.cover_photo_url(:blur_3)
  end

  def update
    @user = current_user.clone

    # this variable may be used for dynamically selecting rendered partial,
    # so be sure it's safe!
    @user_param = user_params.try(:keys).try(:first)
    if %w(unconfirmed_organization_code unconfirmed_department_code unconfirmed_started_year).include?(@user_param)
      @user_param = 'unconfirmed_identity'
    end

    @saved = @user.update(user_params)

    respond_to do |format|
      if @saved
        format.js
      else
        format.js
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :username, :email, :gender, :unconfirmed_organization_code, :unconfirmed_department_code, :unconfirmed_started_year)
  end
end
