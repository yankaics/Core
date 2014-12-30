class User < ActiveRecord::Base
  devise :database_authenticatable, :timeoutable, :registerable, :confirmable,
         :lockable, :recoverable, :rememberable, :trackable, :validatable

  scope :confirmed, -> { where(confirmed_at: nil) }
  scope :unconfirmed, -> { where.not(confirmed_at: nil) }

  has_one :data, class_name: :UserData, dependent: :destroy, autosave: true
  has_many :emails, -> { confirmed }, class_name: :UserEmail, dependent: :destroy, autosave: true
  has_many :unconfirmed_emails, -> { unconfirmed }, class_name: :UserEmail, dependent: :destroy, autosave: true

  accepts_nested_attributes_for :data, allow_destroy: false
  delegate :gender,  :birth_year,  :birth_month,  :birth_day,  :birth_date,  :url,  :brief,  :motto,
           :gender=, :birth_year=, :birth_month=, :birth_day=, :birth_date=, :url=, :brief=, :motto=,
           to: :data, prefix: false, allow_nil: true
  accepts_nested_attributes_for :emails, :unconfirmed_emails, allow_destroy: true

  validates :name, presence: true
  validates_associated :emails, :unconfirmed_emails

  before_create :build_data
  after_save :clear_association_cache

  def initialize(*args, &block)
    super
    @skip_confirmation_notification = true
  end
end
