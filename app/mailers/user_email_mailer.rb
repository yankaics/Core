class UserEmailMailer < ActionMailer::Base
  def confirm(email)
    @email = email
    @user = email.user

    mail to: email.email
  end
end
