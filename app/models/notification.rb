class Notification < ActiveRecord::Base
  scope :unchecked, -> { where(checked_at: nil) }
  scope :unclicked, -> { where(clicked_at: nil) }

  belongs_to :user
  belongs_to :application, class_name: 'Doorkeeper::Application'

  validates :uuid, :user, presence: true

  before_validation :init_uuid
  after_create :send_out!

  def init_uuid
    return if self.uuid.present?
    self.uuid ||= "#{SecureRandom.uuid}-#{SecureRandom.uuid}"
  end

  def click!
    update(clicked_at: Time.now)
    return self
  end

  def send_out!
    UserNotificationSendJob.perform_later(self)
    # ignore push cases currently :p
    # update(push: true, pushed_at: Time.now)
  end

end
