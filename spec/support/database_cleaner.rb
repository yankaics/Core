require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
    DataAPI::Model.remove_connection
    test_api_db = Rails.root.join('db', 'test_api.sqlite3')
    File.delete(test_api_db) if File.exist?(test_api_db)
  end

  config.after(:all) do
    DatabaseCleaner.clean_with(:deletion)
    DataAPI::Model.remove_connection
    test_api_db = Rails.root.join('db', 'test_api.sqlite3')
    File.delete(test_api_db) if File.exist?(test_api_db)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
