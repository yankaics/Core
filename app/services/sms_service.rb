module SMSService
  cattr_accessor :sms_sender

  def self.sender
    return self.sms_sender if self.sms_sender.present?

    case ENV['SMS_DELIVERY_METHOD']
    when 'nexmo'
      self.sms_sender = Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
    end

    return self.sms_sender
  end

  def self.send_message(to: '', text: '')
    case ENV['SMS_DELIVERY_METHOD']
    when 'nexmo'
      self.sender.send_message(from: ENV['APP_NAME'], to: mobile_number(to), text: text, type: 'unicode')
    when 'text'
      Rails.logger.info("SMS: Message to #{mobile_number(to)}: #{text}")
    end
  end

  def self.mobile_number(number)
    number.gsub!(/^0?9/, '+8869')
    number = "+#{number}" unless number.first == '+'
    return number
  end
end
