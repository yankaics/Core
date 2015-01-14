class UserEmailValidator < ActiveModel::Validator
  def validate(record)
    if UserEmail.confirmed.where.not(id: record.id).exists?(email: record.email)
      record.errors[:base] << "This email is already being used."
    end
  end
end

class UserEmail < ActiveRecord::Base
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  belongs_to :user, touch: true
  has_one :associated_user_identity, class_name: UserIdentity, primary_key: :email, foreign_key: :email

  validates :user, :email, presence: true
  validates :email, email_format: true
  validates :confirmation_token, uniqueness: true, allow_nil: true
  validates_with UserEmailValidator

  before_create :generate_confirmation_token
  before_destroy :destroy_corresponding_user_identity

  def self.find_and_confirm(confirmation_token)
    email = find_by(confirmation_token: confirmation_token)
    return false unless email.present? && email.confirmation_sent_at > 6.hours.ago
    email.confirm!
  end

  def confirmed?
    !confirmed_at.blank?
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    self.confirmation_sent_at = Time.now
  end

  def send_confirmation_instructions
    UserEmailMailer.confirm(self).deliver
  end

  def resend_confirmation_instructions
    generate_confirmation_token
    save!
    send_confirmation_instructions
  end

  def confirm
    return false unless valid?
    update(confirmed_at: Time.now)
    # find if there is a predefined identity with this email
    identity = UserIdentity.find_by(user_id: nil, email: email)
    if identity
      identity.update(user: user)
    # or matching email patterns
    elsif (pattern_identity = EmailPattern.identify(email))
      user.identities.create!(pattern_identity)
    end
    return false unless user.valid?
    self
  end

  def confirm!
    confirmed = confirm
    fail unless confirmed
    confirmed
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
