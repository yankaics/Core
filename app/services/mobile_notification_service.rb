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
      apns_dev_pusher.push(apns_notification) if apns_dev_pusher

    when 'android'
      gcm_data = {
        notification: {
          subject: subject,
          message: message,
          tickerText: "#{subject}: #{message}",
          "smallIcon": "ic_logo"
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
        send(device.type, device.device_id, notification.subject, notification.message, url: notification.url, payload: (notification.payload.blank? ? nil : JSON.parse(notification.payload)))  # TODO: deal with badge and sound
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

  def self.apns_dev_certificate_pem_file
    certificate_pem_file = StringIO.new('')

    case ENV['APNS_PEM_STORAGE'] || ENV['APNS_DEV_PEM_STORAGE']
    when 'local'
      begin
        certificate_pem_file = File.open(ENV['APNS_DEV_PEM_PATH'])

      rescue Exception => e
        Rails.logger.error("ApnsService error: #{e}")
      end

    when 's3'
      begin
        certificate_pem_object = aws_service.bucket(ENV['S3_BUCKET']).objects.find(ENV['APNS_DEV_PEM_PATH'])
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

  def self.apns_dev_pusher
    return nil if ENV['APNS_DEV_PEM_PATH'].blank?
    @@apns_pusher ||= Grocer.pusher(
      certificate: apns_dev_certificate_pem_file,
      gateway:     ENV['APNS_DEV_HOST'] || ENV['APNS_HOST'],
      port:        ENV['APNS_DEV_PORT'] || ENV['APNS_PORT'],
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

  def self.send_named_notification(org_code, course_code)
    classmate_data = get_classmate_data(org_code, course_code)

    classmate_data.each do |classmate|
      begin
        message = "#{classmate[:course_name]} 點名了，#{classmate[:course_lecturer]}站在你後面，他非常火！"
        classmate[:user].devices.each do |device|
          if device.type == 'ios'
            MobileNotificationService.send("ios", "#{device.device_id}", "Colorgy 點名通知", message)
          elsif device.type == 'android'
            android_named_notification(device.device_id, message)
            puts device.device_id, message
          end
        end

      rescue Exception => e
      end
    end
  end

  def self.android_named_notification(device_id, message)
    url = URI("https://gcm-http.googleapis.com/gcm/send")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/json'
    request["authorization"] = "key=#{ENV['GCM_API_KEY']}"
    request.body = "{\n    \"to\": \"#{device_id}\",\n    \"data\": {\n    \"notification\": {\n      \"subject\": \"Colorgy 點名通知\",\n      \"message\": \"#{message}\"\n    , \"tickerText\": \"#{message}\" }\n    }\n}"
    http.request(request)
  end

  def self.get_classmate_data(org_code, course_code)
    DataAPI.find_by(name: 'user_courses').data_model.where(course_organization_code: org_code, course_code: course_code).map do |c|
      course = DataAPI.find_by(path: "#{c.course_organization_code.downcase}/courses").data_model.find_by(code: c.course_code)

      {
        course: course,
        course_name: course.name,
        course_lecturer: course.lecturer,
        user_id: c.user_id,
        user: User.find_by_id(c.user_id)
      }
    end
  end
end
