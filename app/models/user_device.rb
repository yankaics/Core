class UserDevice < ActiveRecord::Base
  self.inheritance_column = nil

  TYPES = {
    ios: 1,
    android: 2
  }

  belongs_to :user

  enum type: TYPES

  validates :user, :uuid, :type, presence: true
  validates :uuid, uniqueness: true
  validates :device_id, uniqueness: { scope: [:user_id, :type] }, allow_nil: true

  before_validation :init_uuid

  def init_uuid
    return if self.uuid.present?
    self.uuid ||= SecureRandom.uuid
  end
end
