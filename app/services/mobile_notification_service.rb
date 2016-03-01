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
    payload = {} if payload.nil?
    payload['subject'] = subject
    payload['message'] = message
    payload['url'] = url
    payload['badge'] = badge if badge
    payload['sound_type'] = sound_type

    case type
    when 'ios'
      apns_notification = Grocer::Notification.new(
        device_token:      device_id.gsub(/[\<\>]/, ''),
        alert:             "#{subject}: #{message}",
        custom:            payload,
        sound:             'default'
      )

      apns_notification.badge = badge if badge
      apns_notification.sound = "#{sound_type}.aiff" if sound_type

      apns_pusher.push(apns_notification)

    when 'android'
      gcm_data = {
        notification: {
          subject: subject,
          message: message,
          tickerText: "#{subject}: #{message}"
        },
        payload: payload
      }

      results = HTTParty.post(
        'https://gcm-http.googleapis.com/gcm/send',
        verify: false,
        headers: { 'Authorization' => "key=#{ENV['GCM_API_KEY']}", 'Content-Type' => 'application/json' },
        body: { data: gcm_data, to: device_id }.to_json
      )

      raise StandardError.new(results) if !results.is_a?(Hash) ||
                                          results['failure'] > 0

      results
    end
  end

  # Send mobile notifications for a notification
  def self.send_notification(notification)
    notification.user.devices.each do |device|
      begin
        send(device.type, device.device_id, notification.subject, notification.message, url: notification.url, payload: notification.payload)  # TODO: deal with badge and sound
      rescue Exception => e

      end
    end
  end

  def self.apns_certificate_pem_file
    certificate_pem_file = StringIO.new('')

    case ENV['APNS_PEM_STORAGE']
    when 'local'
      begin
        certificate_pem_file = File.open(ENV['APNS_PEM_PATH'])

      rescue Exception => e
        Rails.logger.error("ApnsService error: #{e}")
      end

    when 's3'
      begin
        certificate_pem_object = aws_service.bucket(ENV['S3_BUCKET']).objects.find(ENV['APNS_PEM_PATH'])
        certificate_text = certificate_pem_object.content
        certificate_pem_file = StringIO.new(certificate_text)

      rescue Exception => e
        Rails.logger.error("ApnsService error: #{e}")
      end
    end

    return certificate_pem_file
  end

  def self.apns_pusher
    @@apns_pusher ||= Grocer.pusher(
      certificate: apns_certificate_pem_file,
      gateway:     ENV['APNS_HOST'],
      port:        ENV['APNS_PORT'],
      retries:     3
    )
  end

  def self.apns_feedback
    @@apns_feedback ||= Grocer.feedback(
      certificate: apns_certificate_pem_file,
      gateway:     ENV['APNS_HOST'],
      port:        ENV['APNS_PORT'],
      retries:     3
    )
  end

  def self.aws_service
    @@aws_service ||= S3::Service.new(access_key_id: ENV['S3_ACCESS_KEY_ID'],
                                      secret_access_key: ENV['S3_SECRET_ACCESS_KEY'])
  end
end
