class UserEmailMailer < ActionMailer::Base
  default from: ENV['MAILER_SENDER']

  def confirm(email)
    @email = email
    @user = email.user

    mail to: email.email, subject: "#{ENV['APP_NAME']} 身分認證信"
  end

  def refuse_user_manual_validation(user)
  	@user = user
  	@email = user.email

  	mail to: @email, subject: "您的 Colorgy 手動驗證已經被拒絕"
  end
end
