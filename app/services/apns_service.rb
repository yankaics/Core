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
    return unless File.exist?(APNS.pem)

    packaged_notifications = []
    map_devices_proc = Proc.new do |noti|
      noti.user.devices.map do |dev|
        if dev.type == 'ios'
          APNS::Notification.new(dev.device_id, alert: "#{noti.subject}: #{noti.message}", sound: 'default', other: { subject: noti.subject ,payload: noti.payload })
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

    APNS.send_notifications(packaged_notifications)

    unload_pem() if Rails.env.production?
  end

  def self.load_pem
    if Rails.env.developement?
      # developement env, check if the pem file exists
      Rails.logger.error("Please replace APNS_PEM_PATH in .env with correct filepath") \
        unless File.exist?(APNS.pem)
    else
      begin
        object = aws_service.buckets.find(ENV['AWS_APNS_BUCKET_NAME']).objects.find(ENV['APNS_PEM_NAME'])
        File.write(APNS.pem, object.content)
      rescue Exception => e
      end
    end

  end

  def self.unload_pem
    File.delete(APNS.pem)
  end

  def self.aws_service
    @@service ||= S3::Service.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
  end
end
