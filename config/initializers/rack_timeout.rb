if Rails.env.test?
  Rack::Timeout.timeout = 60
else
  Rack::Timeout.timeout = (ENV["TIMEOUT_IN_SECONDS"] || 30).to_i
end
