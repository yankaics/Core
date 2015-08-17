module FacebookService
  class << self

    def app_id
      ENV['FB_APP_ID']
    end

    def app_secret
      ENV['FB_APP_SECRET']
    end

    def app_additional_scopes
      (ENV['FB_APP_ADDITIONAL_SCOPES'] || '').split(',')
    end

    def app_scopes
      ['public_profile', 'email'] + app_additional_scopes
    end

    def app_scopes_string
      app_scopes.join(' ')
    end

    def app_me_info_fields
      additional_me_info_fields = []
      app_additional_scopes.each do |scope|
        next unless scope_me_fields[scope.to_sym].is_a?(Array)
        additional_me_info_fields += scope_me_fields[scope.to_sym]
      end
      required_me_info_fields + %w(devices) + additional_me_info_fields
    end

    def app_me_info_fields_string
      app_me_info_fields.join(',')
    end

    def required_me_info_fields
      %w(id email name picture.height(512).width(512) cover gender link)
    end

    def required_me_info_fields_string
      required_me_info_fields.join(',')
    end

    def app_access_token
      return '' if Rails.env.test?
      return @app_access_token if @app_access_token
      @app_access_token = HTTParty.get(
        <<-EOF.squish.delete(' ')
          https://graph.facebook.com//oauth/access_token?
            client_id=#{ENV['FB_APP_ID']}&
            client_secret=#{ENV['FB_APP_SECRET']}&
            grant_type=client_credentials
          EOF
      ).gsub(/.+=/, '')
    end

    def scope_me_fields
      {
        user_birthday: ['birthday', 'age_range'],
        user_friends: ['friends.limit(50000)']
      }
    end
  end
end
