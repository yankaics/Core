require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Core
  VERSION = '0.1'

  class Application < Rails::Application
    Dotenv::Railtie.load if defined? Dotenv::Railtie

    config.active_record.raise_in_transactional_callbacks = true

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.paths.add File.join('app', 'services'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'services', '*')]
    config.paths.add File.join('app', 'jobs'), glob: File.join('**', '*.rb')
    config.autoload_paths += Dir[Rails.root.join('app', 'jobs', '*')]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 8

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :"zh-TW"
    config.i18n.locale = :"zh-TW"

    if ENV['FILE_STORAGE'].try(:upcase) == 'S3'
      config.paperclip_defaults = { storage: :s3, s3_credentials: { bucket: ENV['S3_BUCKET'], access_key_id: ENV['S3_ACCESS_KEY_ID'], secret_access_key: ENV['S3_SECRET_ACCESS_KEY'] }, s3_host_name: ENV['S3_HOST_NAME'], s3_permissions: :public_read, s3_protocol: :https }
    end

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use(Rack::Config) do |env|
      env['api.tilt.root'] = Rails.root.join "app", "api", "views"
    end

    config.middleware.insert_before(0, Rack::Cors) do
      allow do
        origins '*'

        resource '/oauth/*', headers: :any,
                             expose: %w(ETag Status Date Content-Encoding Content-Length Cache-Control Connection Server Link X-Request-Id X-RateLimit-Limit X-RateLimit-Remaining X-RateLimit-Reset X-OAuth-Scopes X-Accepted-OAuth-Scopes X-Poll-Interval X-Items-Count X-Pages-Count),
                             methods: [:get, :post, :delete, :put, :options, :head]
        resource '/api/*', headers: :any,
                           expose: %w(ETag Status Date Content-Encoding Content-Length Cache-Control Connection Server Link X-Request-Id X-RateLimit-Limit X-RateLimit-Remaining X-RateLimit-Reset X-OAuth-Scopes X-Accepted-OAuth-Scopes X-Poll-Interval X-Items-Count X-Pages-Count),
                           methods: [:get, :post, :delete, :patch, :put, :options, :head]
      end
    end

    config.action_mailer.default_url_options = { host: ENV['APP_URL'] }
    config.action_mailer.delivery_method = (ENV['MAILER_DELIVERY_METHOD'].presence || :letter_opener).to_sym

    config.react.addons = true

    case ENV['LOGGER']
    when 'stdout'
      require 'rails_stdout_logging/rails'
      config.logger = RailsStdoutLogging::Rails.heroku_stdout_logger
    when 'remote'
      # Send logs to a remote server
      if !ENV['REMOTE_LOGGER_HOST'].blank? && !ENV['REMOTE_LOGGER_PORT'].blank?
        app_name = ENV['APP_NAME'] || Rails.application.class.parent_name
        config.logger = \
          RemoteSyslogLogger.new(ENV['REMOTE_LOGGER_HOST'], ENV['REMOTE_LOGGER_PORT'],
                                 local_hostname: "#{app_name.underscore}-core-#{Socket.gethostname}".gsub(' ', '_'),
                                 program: ('rails-' + Rails.application.class.parent_name.underscore))
      end
    end
  end
end
