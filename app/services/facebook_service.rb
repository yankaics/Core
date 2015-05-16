module FacebookService
  class << self
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
  end
end
