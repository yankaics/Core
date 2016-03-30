class UserManualValidationsController < ApplicationController
	before_action :authenticate_admin!, only: :index
	before_action :authenticate_user!, only: [:new, :create]

	def index
		@user_manual_validations = UserManualValidation.includes(:user).page(1).per(20)
	end

	def new
		@user_manual_validation = current_user.build_user_manual_validation
	end

	def thank_you_page

	end

	def create
		@user_manual_validation = current_user.build_user_manual_validation(user_manual_validation_params)
		if @user_manual_validation.save
			redirect_to thank_you_page_path
		else
			flash['error'] = @user_manual_validation.errors.full_messages.join("\n")
			render 'new'
		end
	end

	def sso_login
    headers['Access-Control-Allow-Origin'] = '*'
    headers['X-Frame-Options'] = 'ALLOWALL'

    if params[:access_token].present?
      render nothing: true and return if params[:access_token] == '_'

      @access_token = Doorkeeper::AccessToken.by_token(params[:access_token])
      if @access_token && OAuth::AccessTokenValidationService.validate(@access_token) == :valid # &&
         # @access_token.application && @access_token.application.core_app?
        @user = User.find_by(id: @access_token.resource_owner_id)

        if @user
          sign_in @user
          SignonStatusTokenService.write_to_cookie(cookies, @user)
        end
      end

      redirect_to new_user_manual_validation_path
    end

    render nothing: true unless performed?
	end

	private

	def user_manual_validation_params
		params.require(:user_manual_validation).permit(:user_id, :state, :validation_image)
	end
end
