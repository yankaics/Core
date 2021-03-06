class UserData < ActiveRecord::Base
  include EnumHumanizable

  GENDERS = {
    male: 1,
    female: 2,
    other: 3,
    unspecified: 0
  }

  belongs_to :user, touch: true
  belongs_to :unconfirmed_organization, class_name: :Organization,
                                        primary_key: :code,
                                        foreign_key: :unconfirmed_organization_code
  belongs_to :unconfirmed_department,
             ->(o) { (o && o.respond_to?(:unconfirmed_organization_code)) ? where(organization_code: o.unconfirmed_organization_code) : all },
             class_name: :Department,
             primary_key: :code, foreign_key: :unconfirmed_department_code

  enum gender: GENDERS
  serialize :fb_friends
  serialize :fb_devices

  delegate :name, :short_name,
           to: :unconfirmed_organization, prefix: true, allow_nil: true
  delegate :name, :short_name,
           to: :unconfirmed_department, prefix: true, allow_nil: true

  validates :user, presence: true
  validates :birth_month, inclusion: { in: (1..12) }, allow_nil: true
  validates :birth_day, inclusion: { in: (1..31) }, allow_nil: true

  def birth_date
    Date.new(birth_year, birth_month, birth_day) if birth_year && birth_month && birth_day
  end

  def birth_date=(date)
    if date && (date = date.to_date)
      self.birth_year = date.year
      self.birth_month = date.month
      self.birth_day = date.day
    else
      self.birth_year = nil
      self.birth_month = nil
      self.birth_day = nil
    end
  end
end
