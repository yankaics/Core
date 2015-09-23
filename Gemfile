source 'https://rubygems.org'

ruby '2.2.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.2'
# Use sqlite3 or pg as the database for Active Record
gem 'sqlite3', :groups => [:development, :test]
gem 'pg'
# Redis
gem 'redis'
gem 'redis-namespace'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.1'
gem 'compass-rails', '~> 2.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use unicorn as the app server
gem 'unicorn'

gem 'sinatra', :require => nil

# Loads environment variables from `.env`
gem 'dotenv-rails'

# HTTP client
gem 'httparty', '~> 0.13.1'

gem 'aws-sdk', '~> 1.6'

# Job runner and clock
gem 'sidekiq', '~> 3.4.2'
gem 'sidekiq-limit_fetch'
gem 'clockwork', '~> 1.2.0'

# Grape API
gem 'grape', '~> 0.13.0'
gem 'grape-rabl'
gem 'grape-entity'
gem 'grape-swagger'
gem 'api_helper', github: 'Neson/api_helper'
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-oauth2', '~> 1.1.1'

# OAuth 2.0 provider
gem 'doorkeeper', '~> 2.2.0'

# Slim support
gem 'slim-rails'

# Markdown parser
gem 'redcarpet'
gem 'rouge'

# Make SEO-friendly meta tags and titles using meta-tags
gem 'meta-tags', '~> 2.0.0'

# User authentication
gem 'devise', '~> 3.4.0'
gem 'cancancan', '~> 1.10.0'
gem 'omniauth-facebook', '~> 2.0.0'

# ActiveAdmin as the administration framework
gem 'activeadmin', github: 'activeadmin'
gem 'active_admin_import', '2.1.2'

# ActiveRecord view helpers
gem 'simple_form', '~> 3.1.0'
gem 'kaminari'

# Decorators
gem 'draper', '~> 1.3'

# Serializers
gem 'active_model_serializers', '~> 0.8.0'

# ActiveRecord enhancements
gem 'paperclip', '~> 4.3'
gem 'paper_trail', '~> 3.0.6'
gem 'validates_email_format_of'

# Create human-friendly IDs for models
gem 'friendly_id', '~> 5.1.0'
gem 'babosa'
gem 'ruby-pinyin'

# Support bulk inserting data with ActiveRecord
gem 'activerecord-import', '~> 0.7.0'

# Handle settings by rails-settings-cached
gem 'rails-settings-cached', github: 'Neson/rails-settings-cached'

# Model factory and tools
gem 'factory_girl_rails', '~> 4.5.0'
gem 'faker'
gem 'timecop'

# Services
gem 'mailgunner', '~> 2.2.0'
gem 'nexmo'
gem 'twilio-ruby', '~> 4.2.1'
gem 'letter_opener'

# Logger
gem 'remote_syslog_logger'
gem 'rails_stdout_logging', :require => false

# Monitoring
gem 'newrelic_rpm'

# Use Pry as the Rails console
gem 'pry-rails'
gem 'pry-byebug'
gem 'awesome_print', :require => false
gem 'hirb', :require => false
gem 'hirb-unicode', :require => false

# Development tools
group :development do
  gem 'byebug'
  gem 'better_errors', '~> 2.1.0'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'meta_request'
  gem 'bullet'
  gem 'rails-erd'
  gem 'railroady'
end

# RSpec
group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'spring-commands-rspec'
  gem 'shoulda-matchers', require: false
  gem 'rspec-its', require: false
  gem 'rspec-retry', require: false
  gem 'simplecov', '~> 0.10.0', require: false
  gem 'coveralls', require: false
  gem 'codeclimate-test-reporter', require: false
  gem 'selenium-webdriver'
  gem 'capybara-webkit', '>= 1.2.0'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'webmock', require: false
  gem 'formulaic'
  gem 'launchy'
end

# Assets related Gems
gem 'colorgy_style', github: 'colorgy/Style'
gem 'react-rails', '~> 1.0'
gem 'classnames-rails', '~> 0.1.0'
gem 'swagger-ui_rails', '~> 2.1.0.alpha.7.1'
gem 'nprogress-rails', '~> 0.1.6.5'
gem 'select2-rails', '~> 3.5.9'
gem 'chosen-rails'
