class User < ActiveRecord::Base
  include OmniauthCallable
  include FacebookSyncable
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
  has_many :notifications
  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant', foreign_key: :resource_owner_id
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken', foreign_key: :resource_owner_id
  has_many :devices, class_name: :UserDevice
  has_one :user_manual_validation

  delegate :organization, :organization_code, :started_at,
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
           :url,  :brief,  :motto,  :fb_friends,  :fb_devices,
           :url=, :brief=, :motto=, :fb_friends=, :fb_devices=,
           :unconfirmed_organization_code,  :unconfirmed_department_code,  :unconfirmed_started_year,
           :unconfirmed_organization_code=, :unconfirmed_department_code=, :unconfirmed_started_year=,
           :unconfirmed_organization,  :unconfirmed_department,
           :unconfirmed_organization=, :unconfirmed_department=,
           :unconfirmed_organization_name, :unconfirmed_organization_short_name,
           :unconfirmed_department_name, :unconfirmed_department_short_name,
           :avatar_local,  :cover_photo_local,
           :avatar_local=, :cover_photo_local=,
           :avatar_crop_x,  :avatar_crop_y,  :avatar_crop_w,  :avatar_crop_h,
           :avatar_crop_x=, :avatar_crop_y=, :avatar_crop_w=, :avatar_crop_h=,
           to: :data, prefix: false, allow_nil: true
  accepts_nested_attributes_for :emails, :unconfirmed_emails,
                                allow_destroy: true

  has_attached_file :avatar,
                    processors: [:avatar_cropper],
                    styles: { medium: '512x512#', thumb: '256x256>#', grayscale: '512x512>#', blur: '256x256#', blur_2x: '256x256#' },
                    convert_options: { grayscale: '-colorspace Gray', blur: '-blur 0x4', blur_2x: '-blur 0x8' },
                    url: '/system/users/avatars/:style/:hash.:extension',
                    hash_data: ':class/:attachment/:id/:style',
                    hash_secret: ENV['SECRET_KEY_BASE'],
                    preserve_files: true
  validates_attachment_content_type :avatar, content_type: %r{\Aimage\/.*\Z}
  has_attached_file :cover_photo,
                    styles: { large: '2048x2048>', medium: '1024x1024>', thumb: '256x256>', grayscale: '2048x2048>', blur: '1024x1024^', blur_2x: '1024x1024^' },
                    convert_options: { grayscale: '-colorspace Gray', blur: '-blur 0x8', blur_2x: '-blur 0x64 -modulate 100,132,100' },
                    url: '/system/users/cover_photos/:style/:hash.:extension',
                    hash_data: ':class/:attachment/:id/:style',
                    hash_secret: ENV['SECRET_KEY_BASE'],
                    preserve_files: true
  validates_attachment_content_type :cover_photo, content_type: %r{\Aimage\/.*\Z}
  attr_accessor :avatar_crop_pending
  before_update :reset_crop_options_if_avatar_changed
  before_update :reprocess_avatar_if_cropping

  validates :uuid, uniqueness: true
  validates :name, presence: true, on: :update
  validates :username, username: true, uniqueness: true, allow_nil: true
  validates_associated :data, :emails, :unconfirmed_emails

  before_create :generate_uuid, :build_data
  before_validation :generate_uuid, :ensure_user_has_valid_primary_identity, :nilify_blanks
  after_touch :validate_after_touch
  after_save :clear_association_cache
  before_update :download_external_avatar_if_needed, :download_external_cover_photo_if_needed

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

  def nilify_blanks
    self.username = nil if username.blank?
  end

  def organization_codes
    identities.map(&:organization_code)
  end

  def department_codes
    identities.map(&:department_code)
  end

  def possible_organization_code
    organization_code || unconfirmed_organization_code
  end

  def possible_department_code
    department_code || unconfirmed_department_code
  end

  def possible_started_year
    (started_at.try(:year) && started_at.try(:year).to_s) || unconfirmed_started_year
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

  def avatar_url(style = :medium)
    return avatar.url(style) if avatar.present?
    external_avatar_url || "#{ENV['APP_URL']}/assets/defaults/users/avatar.jpg"
  end

  def cover_photo_url(style = :large)
    return cover_photo.url(style) if cover_photo.present?
    external_cover_photo_url || "#{ENV['APP_URL']}/assets/defaults/users/cover_photo.jpg"
  end

  %w(thumb grayscale blur blur_2x).each do |avatar_style|
    define_method "avatar_#{avatar_style}_url" do
      avatar_url(avatar_style)
    end
  end

  %w(thumb grayscale blur blur_2x).each do |cover_photo_style|
    define_method "cover_photo_#{cover_photo_style}_url" do
      cover_photo_url(cover_photo_style)
    end
  end

  def download_external_avatar!
    self.avatar_url = external_avatar_url
    self.save!
  end

  def download_external_cover_photo!
    self.cover_photo_url = external_cover_photo_url
    self.save!
  end

  def download_external_avatar_if_needed
    return unless avatar_updated_at_changed?
    download_external_avatar! if external_avatar_url.present? && avatar.blank?
  end

  def download_external_cover_photo_if_needed
    return unless cover_photo_updated_at_changed?
    download_external_cover_photo! if external_cover_photo_url.present? && cover_photo.blank?
  end

  # Download the avatar from an URL
  def avatar_url=(url)
    self.avatar = open(url)
  rescue OpenURI::HTTPError
    return false
  end

  # Download the cover photo from an URL
  def cover_photo_url=(url)
    self.cover_photo = open(url)
  rescue OpenURI::HTTPError
    return false
  end

  # Does the avatar crop data exists?
  def avatar_crop_data?
    !avatar_crop_x.blank? &&
    !avatar_crop_y.blank? &&
    !avatar_crop_w.blank? &&
    !avatar_crop_h.blank?
  end

  # Will the avatar be cropped on save (avatar_crop_pending set to true and all
  # the required crop data exists)?
  def avatar_cropping?
    avatar_crop_pending && avatar_crop_data?
  end

  # Is this user linked to Facebook?
  def fb_linked?
    fbemail.present?
  end

  # Validate and save the updates after touched
  def validate_after_touch
    reload
    valid?
    save! if changed?
  end

  def check_notifications!
    proceed_notifications = notifications.unchecked
    proceed_notifications_uuids = proceed_notifications.map(&:uuid)
    proceed_notifications.update_all(checked_at: Time.now)
    return notifications.where(uuid: proceed_notifications_uuids)
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

  def reprocess_avatar_if_cropping
    return unless avatar_cropping?
    avatar.reprocess!
  end

  def reset_crop_options_if_avatar_changed
    return unless avatar_updated_at_changed? && !avatar_cropping?
    avatar_crop_x = nil
    avatar_crop_y = nil
    avatar_crop_w = nil
    avatar_crop_h = nil
  end

  PUBLIC_ATTRS = [
    :id,
    :uuid,
    :username,
    :name,
    :avatar_url,
    :avatar_thumb_url,
    :cover_photo_url,
    :cover_photo_thumb_url,
    :avatar_grayscale_url,
    :avatar_blur_url,
    :avatar_blur_2x_url,
    :cover_photo_grayscale_url,
    :cover_photo_blur_url,
    :cover_photo_blur_2x_url
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
    :fbemail
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
    :organization_code,
    :department,
    :department_code,
    :unconfirmed_organization_code,
    :unconfirmed_department_code,
    :unconfirmed_started_year,
    :possible_organization_code,
    :possible_department_code,
    :possible_started_year
  ]

  CORE_ATTRS = [
    :birth_date,
    :fb_friends,
    :fb_devices
  ]

  PERMIT_EDIT_ATTRS = [
    :avatar,
    :avatar_crop_x,
    :avatar_crop_y,
    :avatar_crop_w,
    :avatar_crop_h,
    :cover_photo
  ]

  EDITABLE_ATTRS = [
    :avatar,
    :avatar_crop_x,
    :avatar_crop_y,
    :avatar_crop_w,
    :avatar_crop_h,
    :cover_photo,
    :username,
    :name,
    :gender,
    :birth_year,
    :birth_day,
    :birth_month,
    :brief,
    :motto,
    :url,
    :unconfirmed_organization_code,
    :unconfirmed_department_code,
    :unconfirmed_started_year
  ]
end
