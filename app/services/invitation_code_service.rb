module InvitationCodeService
  class << self
    def generate(email)
      email_base64 = Base64.encode64(email)
      key = Digest::SHA256.hexdigest(email + Digest::SHA256.hexdigest(email + secret_key))
      "#{email_base64}.#{key}"
    end

    def verify(code)
      code_split = code.split('.')
      email = Base64.decode64(code_split[0])
      code_gen = generate(email)
      if code_gen == code
        email
      else
        nil
      end
    end

    private

    def secret_key
      @secret_key ||= ENV['INVITATION_CODE_KEY']
    end
  end
end
