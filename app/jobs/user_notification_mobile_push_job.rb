class UserNotificationMobilePushJob < ActiveJob::Base
  queue_as :default

  def perform(notification)
    MobileNotificationService.send_notification(notification)
    notification.update(pushed_at: Time.now)
  end
end
