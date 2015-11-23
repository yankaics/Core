# Setup APNS

# APNS.host = ENV['APNS_HOST']
# APNS.port = ENV['APNS_PORT'] && ENV['APNS_PORT'].to_i
# APNS.pem  = Rails.root.join('tmp', ENV['APNS_PEM_NAME'])

APN = Houston::Client.production if Rails.env.production?
APN = Houston::Client.development if Rails.env.development? || Rails.env.test?
