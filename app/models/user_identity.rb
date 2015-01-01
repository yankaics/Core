class UserIdentityValidator < ActiveModel::Validator
  def validate(record)
    if record.department.presence
      record.errors[:base] << "Illegal department." if record.organization_code != record.department.organization_code
      return if record.permit_changing_department_in_organization
      return unless record.original_department_code.presence
      if record.permit_changing_department_in_group
        record.errors[:base] << "Changing the department to a different group from the original one is not permitted for this identity." if record.department.group != record.original_department.group
      elsif record.department_code != record.original_department_code
        record.errors[:base] << "Changing the department against the original one is not permitted for this identity."
      end
    end
  end
end

class UserIdentity < ActiveRecord::Base
  IDENTITES = {
    guest: 0,
    student: 1,
    staff: 2,
    lecturer: 3,
    professor: 4
  }

  scope :generated, -> { where.not(email_pattern_id: nil) }
  scope :predefined, -> { where(email_pattern_id: nil) }

  belongs_to :user, touch: true
  belongs_to :associated_user_email, class_name: UserEmail, primary_key: :email, foreign_key: :email
  has_one :primary_user, class_name: :User, foreign_key: :primary_identity_id
  belongs_to :email_pattern
  belongs_to :organization, primary_key: :code, foreign_key: :organization_code
  belongs_to :department, ->(o) { where(organization_code: o.organization_code) }, primary_key: :code, foreign_key: :department_code
  belongs_to :original_department, ->(o) { where(organization_code: o.organization_code) }, class_name: Department, primary_key: :code, foreign_key: :original_department_code

  enum identity: IDENTITES

  validates :uid, presence: true
  validates :email, presence: true
  validates :organization, presence: true
  validates_with UserIdentityValidator

  after_validation :ensure_user_identity_has_valid_original_department
  before_save :link_to_user

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
