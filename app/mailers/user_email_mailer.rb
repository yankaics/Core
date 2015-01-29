class UserEmailMailer < ActionMailer::Base
  default from: ENV['MAILER_SENDER']

  def confirm(email)
    @email = email
    @user = email.user

    mail to: email.email, subject: "#{ENV['APP_NAME']} 身分認證信"
  end
end
