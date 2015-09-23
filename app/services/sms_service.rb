module SMSService
  cattr_accessor :sms_sender

  def self.sender
    return self.sms_sender if self.sms_sender.present?

    case ENV['SMS_DELIVERY_METHOD']
    when 'nexmo'
      self.sms_sender = Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
    when 'twilio'
      self.sms_sender = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    end

    return self.sms_sender
  end

  def self.send_message(to: '', text: '')
    case ENV['SMS_DELIVERY_METHOD']
    when 'nexmo'
      self.sender.send_message(
        from: ENV['APP_NAME'],
        to: mobile_number(to),
        text: text,
        type: 'unicode'
      )
    when 'twilio'
      self.sender.messages.create(
        from: ENV['TWILIO_FROM_NUMBER'],
        to: mobile_number(to),
        body: text
      )
    when 'test'
      Rails.logger.info("SMS: Message to #{mobile_number(to)}: #{text}")
    end

    return {}
  rescue Twilio::REST::RequestError, Nexmo::Error => e
    return { error: e.to_s }
  end

  def self.mobile_number(number)
    number.gsub!(/^0?9/, '+8869')
    number = "+#{number}" unless number.first == '+'
    return number
  end
end
