class UserEmail < ActiveRecord::Base
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  belongs_to :user, touch: true

  validates :user, :email, presence: true
  validates :email, email_format: true

  before_destroy :destroy_corresponding_user_identity

  def confirmed?
    !confirmed_at.blank?
  end

  def confirm
    update(confirmed_at: Time.now)
    # find if there is a predefined identity with this email
    identity = UserIdentity.find_by(user_id: nil, email: email)
    if identity
      identity.update(user: user)
    # or matching email patterns
    elsif (pattern_identity = EmailPattern.identify(email))
      user.identities.create!(pattern_identity)
    end
    fail unless user.valid?
    self
  end

  def confirm!
    confirm
  end

  private

  def destroy_corresponding_user_identity
    user_identity = UserIdentity.find_by(email: email)
    return unless user_identity
    if user_identity.email_pattern_id
      user_identity.destroy
    else
      user_identity.update_column(:user_id, nil)
    end
  end
end
