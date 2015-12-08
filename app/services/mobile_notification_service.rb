##
# MobileNotificationService
# support multiple device tokens push
#
# Example:
#
#   MobileNotificationService.send_notification(notification)
#   # which notification is a Notification intense
#
# Notification class schema:
# subject
# message
# url
# payload
#
# APNS arguments
# :device_token, :alert, :badge, :sound, :other, :priority
# :message_identifier, :expiration_date
# :content_available

module MobileNotificationService

  # Send a raw notification to a device
  def self.send(type, device_id, subject, message, url: nil, badge: nil, sound_type: nil, payload: {})
    load_apns_pem if !APN.certificate && Rails.env.production?
    payload['subject'] = subject
    payload['message'] = message
    payload['url'] = url
    payload['badge'] = badge if badge
    payload['sound_type'] = sound_type

    case type
    when 'ios'
      apn_notification = Houston::Notification.new(
        device: device_id,
        alert: "#{noti.subject}: #{noti.message}",
        custom_data: payload
      )
      apn_notification.badge = badge if badge
      apn_notification.sound = "#{sound_type}.aiff" if sound_type

      APN.push(apn_notification)
    when 'android'
      # TODO
    end
  end

  # Send mobile notifications fore a notification
  def self.send_notification(notification)
    load_apns_pem if !APN.certificate && Rails.env.production?

    notification.user.devices.each do |device|
      send(device.type, device.device_id, notification.subject, notification.message, url: notification.url)  # TODO: deal with badge and sound
    end
  end

  def self.load_apns_pem
    case ENV['APNS_PEM_STORAGE']
    when 'local'
      begin
        certificate_pem_file = File.open(ENV['APNS_PEM_PATH'])
        APN.certificate = certificate_pem_file.read
      rescue Exception => e
        Rails.logger.error("ApnsService error: #{e}")
      end

    when 's3'
      begin
        certificate_pem_object = aws_service.bucket(ENV['S3_BUCKET']).objects.find(ENV['APNS_PEM_PATH'])
        APN.certificate = certificate_pem_object.content
      rescue Exception => e
        Rails.logger.error("ApnsService error: #{e}")
      end
    end
  end

  def self.aws_service
    @@aws_service ||= S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY_ID'],
                                      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'])
  end
end
