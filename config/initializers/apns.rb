# Setup APNS

APNS.host = ENV['APNS_HOST']
APNS.port = ENV['APNS_PORT'] && ENV['APNS_PORT'].to_i
APNS.pem  = Rails.root.join('tmp', ENV['APNS_PEM_NAME'])
