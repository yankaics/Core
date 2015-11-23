##
# a wrapper for APNS gem
# support multiple device tokens push
#
# Example
#
#   ApnsService.send_notification(notification)
#   which notification is a Notification object

# APNS arguments
# :device_token, :alert, :badge, :sound, :other, :priority
# :message_identifier, :expiration_date
# :content_available

# Notification class schema:
# subject
# message
# url
# payload

module ApnsService
  def self.send_notification notification
    load_pem() if Rails.env.production?
    return unless File.exist?(apns_pem_path)

    packaged_notifications = []
    map_devices_proc = Proc.new do |noti|
      noti.user.devices.map do |dev|
        if dev.type == 'ios'
          Houston::Notification.new(
            device: dev.device_id,
            alert: "#{noti.subject}: #{noti.message}"
          )
        elsif dev.type == 'android'
          nil
        end
      end
    end

    if notification.is_a?(ActiveRecord::Relation) || notification.is_a?(Array)
      packaged_notifications = notification.reduce([]) do |arr, noti|
        notices = map_devices_proc.call(noti)
        arr.concat(notices)
      end
    else
      packaged_notifications = map_devices_proc.call(notification)
    end

    packaged_notifications.reject!(&:nil?)
    packaged_notifications.each{|noti| APN.push(noti) } if Rails.env.production?

    unload_pem() if Rails.env.production?
  end

  def self.load_pem
    if Rails.env.production?
      begin
        object = aws_service.bucket(ENV['S3_BUCKET']).objects.find(ENV['APNS_PEM_NAME'])
        # File.write(apns_pem_path, object.content)
        APN.certificate = object.content
      rescue Exception => e
      end
    else
      # developement env, check if the pem file exists
      Rails.logger.error("Please replace APNS_PEM_PATH in .env with correct filepath") \
        unless File.exist?(apns_pem_path)
    end

  end

  def self.unload_pem
    File.delete(apns_pem_path) if File.exist?(apns_pem_path)
  end

  def self.aws_service
    @@service ||= S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY_ID'],
                                  secret_access_key: ENV['S3_SECRET_ACCESS_KEY'])
  end

  def self.apns_pem_path
    Rails.root.join('tmp', ENV['APNS_PEM_NAME'])
  end

end
