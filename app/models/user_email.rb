class UserEmail < ActiveRecord::Base
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  belongs_to :user, touch: true

  validates :user, :email, presence: true
  validates :email, email_format: true

  # before_destroy

  def confirmed?
    !confirmed_at.blank?
  end

  def confirm
    update(confirmed_at: Time.now)
    self
  end

  def confirm!
    confirm
  end
end
