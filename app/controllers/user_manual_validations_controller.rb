class UserManualValidationsController < ApplicationController
	# before_action :authenticate_admin!, only: [:index, :update_user_org_code]
	before_action :authenticate_user!, only: [:new, :create]

	def index
    @user_manual_validations = UserManualValidation.where.not(user_id: nil)
		@user_manual_validations = @user_manual_validations.order("created_at DESC").includes(:user)
	end

	def new
		@user_manual_validation = current_user.build_user_manual_validation
	end

  def gender
    @users = User.includes(:data).where(user_data: {gender: 0})
  end

  def update_user_gender
    user_id = params[:user_id].to_i
    gender = params[:gender].to_s
    @user = User.find(user_id)
    if @user.name.blank?
      @user.name = '無名氏'
    end
    @user.gender = gender

    respond_to do |format|
      if @user.save
        format.json { render json:
          {
            state: 'success',
            user: @user,
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

  def send_success_notification
    @user = User.find(params[:user_id].to_i)
    @user.devices.each do |device|
      begin
        MobileNotificationService.send(device.type, device.device_id, 'Colorgy 學生證開通成功', '把 App 關掉重開即可唷！')
      rescue Exception => e
      end
    end

    respond_to do |format|
      format.json { render json:
        {
          state: 'success'
        }
      }
    end
  end

  def send_error_notification
    @user = User.find(params[:user_id].to_i)
    @user.devices.each do |device|
      begin
        MobileNotificationService.send(device.type, device.device_id, 'Colorgy 學生證開通失敗', '可能因為你沒有跟學生證合照或是照片太不清楚哦，可以連繫粉專。')
      rescue Exception => e
      end
    end

    respond_to do |format|
      format.json { render json:
        {
          state: 'success'
        }
      }
    end
  end

	def update_user_org_code
		org = params[:org]
		validation_id = params[:validation_id].to_i
		user_id = params[:user_id].to_i
    gender = params[:gender].to_s
		@user_manual_validation = UserManualValidation.find(validation_id)
		@user = User.find(user_id)

    @user.gender = gender
		@user.unconfirmed_organization_code = org

    confirm_user!(@user, org)

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

  def confirm_user! user, org
    email = user.email
    uid = email.match(/^[^@]+/)[0]
    identity = UserIdentity.create!(
      name: user.name,
      email: email,
      organization_code: org,
      identity: 1,
      uid: uid,
      permit_changing_department_in_group: true,
      permit_changing_department_in_organization: true
    )
    user_email = user.emails.create!(email: email)
    user_email.confirm!
  end
end
