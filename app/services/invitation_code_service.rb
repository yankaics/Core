module InvitationCodeService
  class << self
    def generate(email)
      email_base64 = Base64.encode64(email)
      key = Digest::SHA256.hexdigest(email + Digest::SHA256.hexdigest(email + secret_key))
      "#{email_base64}.#{key}".gsub(/[^\.a-zA-Z0-9]/, '')
    end

    def verify(code)
      return nil unless code
      code_split = code.split('.')
      email = Base64.decode64(code_split[0])
      code_gen = generate(email)
      if code_gen == code
        email
      else
        nil
      end
    end

    def invite(user, code)
      email = verify(code)
      return nil unless email
      ActiveRecord::Base.transaction do
        user.confirm! if !user.confirmed? && user.email == email
        user.emails.create(email: email)
        user.unconfirmed_emails.find_by(email: email).confirm!
      end
      user.reload
    end

    private

    def secret_key
      @secret_key ||= ENV['INVITATION_CODE_KEY']
    end
  end
end
