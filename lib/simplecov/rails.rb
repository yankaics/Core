require 'simplecov'

SimpleCov.profiles.define :rails_cov do
  load_profile :rails
  add_group 'API', 'app/api'
  add_group 'Serializers', 'app/serializers'
  add_group 'Services', 'app/services'
  add_group 'Decorators', 'app/decorators'

  add_group "Long files" do |src_file|
    src_file.lines.count > 100
  end
end
