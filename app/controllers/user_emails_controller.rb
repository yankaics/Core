class UserEmailsController < ApplicationController
  before_action :authenticate_user!, except: [:confirm]

  def index
    @emails = current_user.all_emails
    @confirmed_emails = @emails.confirmed
    @unconfirmed_emails = @emails.unconfirmed
  end

  def new
    @email = current_user.emails.build
    @email_patterns = EmailPattern.includes(:organization).all.serialize_it.as_json
  end

  def create
    @email = current_user.emails.create(user_email_params)
    @email.send_confirmation_instructions

    redirect_to :action => :index
  end

  def update
    @email = current_user.unconfirmed_emails.find(params[:id])
    @email.resend_confirmation_instructions

    redirect_to :action => :index
  end

  def confirm
    @email = UserEmail.find_and_confirm(params[:confirmation_token])

    redirect_to :action => :index
  end

  def destroy
    current_user.all_emails.find(params[:id]).destroy

    redirect_to :action => :index
  end

  def query_departments
    @departments = Department.where(organization_code: params[:organization_code])
                   .select(:name, :short_name, :parent_code, :code, :group)
    @departments = Hash[@departments.map { |obj| [obj.code, obj] }]

    @departments[:organization_code] = params[:organization_code]

    respond_to do |format|
      format.json { render json: @departments }
    end
  end

  private

  def user_email_params
    params.require(:user_email).permit(:email, :department_code)
  end
end
