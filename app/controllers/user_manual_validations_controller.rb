class UserManualValidationsController < ApplicationController
	before_action :authenticate_admin!, only: [:index, :update_user_org_code]
	before_action :authenticate_user!, only: [:new, :create]

	def index
    @user_manual_validations = UserManualValidation.where.not(user_id: nil)
		@user_manual_validations = @user_manual_validations.order("created_at DESC").includes(:user)
	end

	def new
		@user_manual_validation = current_user.build_user_manual_validation
	end

  def destroy
    @user_manual_validation = UserManualValidation.find(params[:id])

    if @user_manual_validation.destroy
      redirect_to user_manual_validations_path
    end
  end

  def refuse_user
    validation_id = params[:validation_id].to_i
    user_id = params[:user_id].to_i
    @user_manual_validation = UserManualValidation.find(validation_id)
    @user = User.find(user_id)
    @user_manual_validation.state = 'refused'

    respond_to do |format|
      if @user_manual_validation.save

        format.json { render json:
          {
            state: 'success',
            user_manual_validation: @user_manual_validation
          }
        }
      else
        format.json { render json:
          {
            state: 'error',
            error: @user_manual_validation.errors.full_messages
          }
        }
      end
    end
  end

	def update_user_org_code
		org = params[:org]
		validation_id = params[:validation_id].to_i
		user_id = params[:user_id].to_i
		@user_manual_validation = UserManualValidation.find(validation_id)
		@user = User.find(user_id)
		@user.unconfirmed_organization_code = org

    respond_to do |format|
      if @user.save
      	@user_manual_validation.update({ state: 'passed' })
        format.json { render json:
          {
            state: 'success',
            user: @user,
            user_manual_validation: @user_manual_validation
          }
        }
      else
        format.json { render json:
          {
            state: 'error',
            error: @user.errors.full_messages
          }
        }
      end
    end
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

    end
    redirect_to new_user_manual_validation_path

    render nothing: true unless performed?
	end

	private

	def user_manual_validation_params
		params.require(:user_manual_validation).permit(:user_id, :state, :validation_image)
	end
end
