module CoreRSAKeyService
  class << self
    def private_key_string
      @private_key_string ||= if ENV['CORE_RSA_PRIVATE_KEY_1'].present?

                                ENV['CORE_RSA_PRIVATE_KEY'] = [
                                  ENV['CORE_RSA_PRIVATE_KEY_1'],
                                  ENV['CORE_RSA_PRIVATE_KEY_2'],
                                  ENV['CORE_RSA_PRIVATE_KEY_3'],
                                  ENV['CORE_RSA_PRIVATE_KEY_4']
                                ].join

                                ENV['CORE_RSA_PRIVATE_KEY'].gsub(/\\n/, "\n")
                              else
                                ENV['CORE_RSA_PRIVATE_KEY'].gsub(/\\n/, "\n")
                              end
    end

    def public_key_string
      @public_key_string ||=
      if ENV['CORE_RSA_PUBLIC_KEY'].present?
        ENV['CORE_RSA_PUBLIC_KEY'].gsub(/\\n/, "\n")
      else
        private_key.public_key.to_s
      end
    end

    def private_key
      @private_key ||= OpenSSL::PKey::RSA.new(private_key_string)
    end

    def public_key
      @public_key ||= OpenSSL::PKey::RSA.new(public_key_string)
    end

    def domain
      @domain ||= URI.parse(ENV['APP_URL']).host
    end
  end
end
