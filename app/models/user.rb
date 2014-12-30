class User < ActiveRecord::Base
  devise :database_authenticatable, :timeoutable, :registerable, :confirmable,
         :lockable, :recoverable, :rememberable, :trackable, :validatable

  scope :confirmed, -> { where(confirmed_at: nil) }
  scope :unconfirmed, -> { where.not(confirmed_at: nil) }

  has_one :data, class_name: :UserData, dependent: :destroy, autosave: true

  accepts_nested_attributes_for :data, allow_destroy: false
  delegate :gender,  :birth_year,  :birth_month,  :birth_day,  :birth_date,  :url,  :brief,  :motto,
           :gender=, :birth_year=, :birth_month=, :birth_day=, :birth_date=, :url=, :brief=, :motto=,
           to: :data, prefix: false, allow_nil: true

  validates :name, presence: true

  before_create :build_data

  def initialize(*args, &block)
    super
    @skip_confirmation_notification = true
  end
end
