class UserIdentity < ActiveRecord::Base
  include EnumHumanizable

  IDENTITIES = {
    guest: 0,
    student: 1,
    staff: 2,
    lecturer: 3,
    professor: 4
  }

  scope :generated, -> { where.not(email_pattern_id: nil) }
  scope :predefined, -> { where(email_pattern_id: nil) }
  scope :linked, -> { where.not(user_id: nil) }
  scope :unlinked, -> { where(user_id: nil) }

  belongs_to :user, touch: true
  belongs_to :associated_user_email, class_name: UserEmail, primary_key: :email, foreign_key: :email
  has_one :primary_user, class_name: :User, foreign_key: :primary_identity_id
  belongs_to :email_pattern
  belongs_to :organization, primary_key: :code, foreign_key: :organization_code
  belongs_to :department, ->(o) { (o && o.respond_to?(:organization_code)) ? where(organization_code: o.organization_code) : all },
             primary_key: :code, foreign_key: :department_code
  belongs_to :original_department, ->(o) { (o && o.respond_to?(:organization_code)) ? where(organization_code: o.organization_code) : all }, class_name: Department, primary_key: :code, foreign_key: :original_department_code

  enum identity: IDENTITIES

  delegate :name, :short_name,
           to: :organization, prefix: true, allow_nil: true
  delegate :name, :short_name,
           to: :department, prefix: true, allow_nil: true
  delegate :name, :short_name,
           to: :original_department, prefix: true, allow_nil: true

  validates :uid, presence: true
  validates :email, presence: true, uniqueness: { scope: :organization_code }
  validates :organization, presence: true
  validates_with UserIdentityValidator

  after_validation :ensure_user_identity_has_valid_original_department
  before_save :link_to_user

  def self.identity_attributes_for_select
    IDENTITIES.map { |k, v| [I18n.t(k, scope: :'activerecord.attributes.user_identity.identities'), k] }
  end

  def ensure_user_identity_has_valid_original_department
    return unless department.presence && !original_department.presence
    self.original_department = department
  end

  def link_to_user
    return if true && email_pattern_id  # don't care about generated identities
    user_email = UserEmail.confirmed.find_by(email: email)
    if user_email
      self.user = user_email.user
    else
      self.user = nil
    end
  end
end
