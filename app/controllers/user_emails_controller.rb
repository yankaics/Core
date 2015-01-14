class UserEmailsController < ApplicationController
  before_action :authenticate_user!

  def index
    @emails = current_user.all_emails
    @confirmed_emails = @emails.confirmed
    @unconfirmed_emails = @emails.unconfirmed
  end

  def new
    @email = current_user.emails.build
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
    @email = current_user.unconfirmed_emails.find_and_confirm(params[:confirmation_token])

    redirect_to :action => :index
  end

  def destroy
    current_user.all_emails.find(params[:id]).destroy

    redirect_to :action => :index
  end

  private

  def user_email_params
    params.require(:user_email).permit(:email)
  end
end
