class UserData < ActiveRecord::Base
  GENDERS = {
    male: 1,
    female: 2,
    other: 3,
    null: 0
  }

  belongs_to :user, touch: true

  enum gender: GENDERS

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
