class UserEmail < ActiveRecord::Base
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }

  belongs_to :user, touch: true
  has_one :associated_user_identity, class_name: UserIdentity, primary_key: :email, foreign_key: :email

  store :options, accessors: [:department_code]

  delegate :organization, :organization_name, :organization_short_name,
           :department, :department_name, :department_short_name,
           :original_department, :original_department_name,
           :original_department_short_name,
           :identity, :name,
           to: :associated_user_identity, prefix: true, allow_nil: true

  validates :user, :email, presence: true
  validates :email, email_format: true, uniqueness: { scope: :user_id }
  validates :confirmation_token, uniqueness: true, allow_nil: true
  validates_with UserEmailValidator

  after_initialize :strip_email
  before_validation :strip_email
  before_create :generate_confirmation_token
  before_destroy :destroy_corresponding_user_identity

  def self.find_and_confirm(confirmation_token)
    email = find_by(confirmation_token: confirmation_token)
    return false unless email.present? && email.confirmation_sent_at > 6.hours.ago
    email.confirm!
  end

  def confirmed?
    confirmed_at.present?
  end

  def strip_email
    email.strip! if email.present?
  end

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(36)
    self.confirmation_sent_at = Time.now
  end

  def send_confirmation_instructions
    UserEmailMailer.confirm(self).deliver_now
  end

  def resend_confirmation_instructions
    generate_confirmation_token
    save!
    send_confirmation_instructions
  end

  def linked_associated_user_identity
    return nil if associated_user_identity.blank?
    associated_user_identity.user_id == user_id ? associated_user_identity : nil
  end

  def identify
    # find if there is a predefined identity with this email
    identity = UserIdentity.find_by(user_id: nil, email: email)
    if identity
      identity.user = user
      identity.department_code = department_code unless department_code.blank?
    # or matching email patterns
    elsif (pattern_identity = EmailPattern.identify(email))
      identity = user.identities.build(pattern_identity)
      identity.department_code = department_code unless department_code.blank?
    end

    return identity
  end

  def identify!
    # skip if already identified
    return if linked_associated_user_identity.present?

    transaction do
      identity = identify
      identity.save! if identity
    end
  end

  def re_identify!
    reload

    # skip if the associated user_identity is predefined
    return if linked_associated_user_identity.present? && !linked_associated_user_identity.generated?

    # get the new expected identity and check if it equals the old one
    new_identity = identify
    if (new_identity.present? &&
        linked_associated_user_identity.present? &&
        linked_associated_user_identity.attributes.except('id', 'department_code', 'created_at', 'updated_at') !=
        new_identity.attributes.except('id', 'department_code', 'created_at', 'updated_at')) ||
       (new_identity.present? && linked_associated_user_identity.blank?)

      # use the new one
      transaction do
        if linked_associated_user_identity.present?
          # set the user changeable attributes of the new identity to those of the old one
          new_identity.department_code = linked_associated_user_identity.department_code
          # destroy the old user_identity
          linked_associated_user_identity.destroy!
        end

        new_identity.save!(validate: false)
      end
    end
  end

  def confirm
    return false unless valid?
    transaction do
      update(confirmed_at: Time.now, confirmation_token: nil)
      identify!
    end
    return false unless user.reload.valid?
    self
  end

  def confirm!
    confirmed = confirm
    fail unless confirmed
    confirmed
  end

  def can_skip_confirmation?
    pattern = EmailPattern.identify(email)
    pattern.present? && pattern[:skip_confirmation]
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
