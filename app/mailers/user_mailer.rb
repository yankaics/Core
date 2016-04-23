class UserMailer < Devise::Mailer
  default from: ENV['MAILER_SENDER']

  def confirmation_instructions(record, token, opts={})
    opts[:subject] = "#{ENV['APP_NAME']} 帳號認證信"
    super
  end

end
