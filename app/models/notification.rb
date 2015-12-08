class Notification < ActiveRecord::Base
  scope :unchecked, -> { where(checked_at: nil) }
  scope :unclicked, -> { where(clicked_at: nil) }

  belongs_to :user
  belongs_to :application, class_name: 'Doorkeeper::Application'

  validates :uuid, :user, presence: true

  before_validation :init_uuid
  after_create :send_mobile_notification_if_needed

  def init_uuid
    return if self.uuid.present?
    self.uuid ||= "#{SecureRandom.uuid}-#{SecureRandom.uuid}"
  end

  def click!
    update(clicked_at: Time.now)
    return self
  end

  def send_mobile_notification_if_needed
    UserNotificationMobilePushJob.perform_later(self) if push
  end
end
