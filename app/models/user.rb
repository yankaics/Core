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
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', as: :resource_owner
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', as: :resource_owner

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
  validates_associated :emails, :unconfirmed_emails

  before_create :build_data
  before_validation :ensure_user_has_valid_primary_identity
  after_touch :save!
  after_save :clear_association_cache

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

  private

  def ensure_user_has_valid_primary_identity
    if identities.count > 0
      self.primary_identity = identities.first if primary_identity.nil?
    else
      self.primary_identity = nil
    end
  end

  PUBLIC_ATTRS = [
    :id,
    :username,
    :name,
    :avatar_url,
    :cover_photo_url,
    :gender
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
end
