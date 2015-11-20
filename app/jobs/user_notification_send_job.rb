class UserNotificationSendJob < ActiveJob::Base
  queue_as :default

  def perform(notification)
    ApnsService.send_notification(notification)
  end
end
