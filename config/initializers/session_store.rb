# Be sure to restart your server when you modify this file.

if ENV['URL_TLD'] == 'false'
  Rails.application.config.session_store :cookie_store, key: '_Core_session'
else
  Rails.application.config.session_store :cookie_store, key: '_Core_session', domain: :all
end
