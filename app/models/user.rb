class User < ActiveRecord::Base
  include OmniauthCallable
  devise :database_authenticatable, :timeoutable, :registerable, :confirmable,
         :lockable, :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook]

  scope :with_data, -> { includes(:data) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }
  scope :unconfirmed, -> { where(confirmed_at: nil) }
  scope :identified, -> { where.not(primary_identity: nil) }
  scope :unidentified, -> { where(primary_identity: nil) }

  has_one :data, class_name: :UserData, dependent: :destroy, autosave: true
  has_many :all_emails,
           class_name: :UserEmail, dependent: :destroy, autosave: true
  has_many :emails, -> { confirmed },
           class_name: :UserEmail, dependent: :destroy, autosave: true
  has_many :unconfirmed_emails, -> { unconfirmed },
           class_name: :UserEmail, dependent: :destroy, autosave: true
  has_many :identities, class_name: :UserIdentity
  has_many :organizations,
           through: :identities,
           primary_key: :code, foreign_key: :organization_code
  has_many :departments,
           through: :identities,
           primary_key: :code, foreign_key: :department_code
  belongs_to :primary_identity, class_name: :UserIdentity
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', foreign_key: :resource_owner_id
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id

  delegate :organization, :organization_code,
           :department, :department_code, :uid, :identity,
           to: :primary_identity, prefix: false, allow_nil: true
  delegate :name, :short_name,
           to: :organization, prefix: true, allow_nil: true
  delegate :name, :short_name,
           to: :department, prefix: true, allow_nil: true
  accepts_nested_attributes_for :data, allow_destroy: false
  delegate :mobile,  :unconfirmed_mobile,  :mobile_confirmation_token,
           :mobile=, :unconfirmed_mobile=, :mobile_confirmation_token=,
           :mobile_confirmation_sent_at,  :mobile_confirm_tries,
           :mobile_confirmation_sent_at=, :mobile_confirm_tries=,
           :gender,  :birth_year,  :birth_month,  :birth_day,  :birth_date,
           :gender=, :birth_year=, :birth_month=, :birth_day=, :birth_date=,
           :url,  :brief,  :motto,  :fb_friends,  :devices,
           :url=, :brief=, :motto=, :fb_friends=, :devices=,
           to: :data, prefix: false, allow_nil: true
  accepts_nested_attributes_for :emails, :unconfirmed_emails,
                                allow_destroy: true

  validates :name, presence: true, on: :update
  validates_associated :data, :emails, :unconfirmed_emails

  before_create :generate_uuid, :build_data
  before_validation :generate_uuid, :ensure_user_has_valid_primary_identity
  after_touch :validate_after_touch
  after_save :clear_association_cache

  def self.scoped(org_code)
    if org_code.blank?
      all
    else
      org = Organization.find_by(code: org_code)
      org ? org.users : none
    end
  end

  def initialize(*args, &block)
    super
    @skip_confirmation_notification = true
  end

  def organization_codes
    identities.map(&:organization_code)
  end

  def department_codes
    identities.map(&:department_code)
  end

  def verified?
    !primary_identity_id.blank?
  end

  def generate_uuid
    return if uuid.present?
    regenerate_uuid(true)
  end

  def regenerate_uuid(random = true)
    if random
      base = SecureRandom.random_bytes(16)
    else
      base = Digest::MD5.digest("#{ENV['APP_URL']}#{id}")
    end
    ary = base.unpack("NnnnnN")
    ary[2] = (ary[2] & 0x0fff) | 0x4000
    ary[3] = (ary[3] & 0x3fff) | 0x8000
    self.uuid = "%08x-%04x-%04x-%04x-%04x%08x" % ary
  end

  def avatar_url
    external_avatar_url
  end

  def cover_photo_url
    external_cover_photo_url
  end

  def fb_linked?
    fbemail.present?
  end

  # Validate and save the updates after touched
  def validate_after_touch
    reload
    valid?
    save! if changed?
  end

  private

  def ensure_user_has_valid_primary_identity
    if identities.count > 0
      self.primary_identity = identities.first if primary_identity.nil?
      self.primary_identity = identities.first if primary_identity.user_id != self.id
    else
      self.primary_identity = nil
    end
  end

  PUBLIC_ATTRS = [
    :id,
    :uuid,
    :username,
    :name,
    :avatar_url,
    :cover_photo_url
  ]

  EMAIL_ATTRS = [
    :email
  ]

  ACCOUNT_ATTRS = [
    :sign_in_count,
    :created_at,
    :updated_at,
    :last_sign_in_at
  ]

  FB_ATTRS = [
    :fbid,
    :fb_friends
  ]

  INFO_ATTRS = [
    :gender,
    :birth_year,
    :birth_day,
    :birth_month,
    :brief,
    :motto,
    :url
  ]

  IDENTITY_ATTRS = [
    :emails,
    :identities,
    :primary_identity,
    :identity,
    :uid,
    :organizations,
    :departments,
    :organization,
    :department
  ]

  CORE_ATTRS = [
    :devices,
    :birth_date,
    :fb_friends
  ]

  EDITABLE_ATTRS = [
    :username,
    :name,
    :gender,
    :birth_year,
    :birth_day,
    :birth_month,
    :brief,
    :motto,
    :url
  ]
end
