module OAuthApplication
  extend ActiveSupport::Concern

  included do
    scope :user_apps, -> { where("owner_type = ?", 'User') }
    scope :core_apps, -> { where("owner_type = ?", 'Admin') }

    before_create :set_initial_refresh_time
  end

  module ClassMethods
  end

  def core_app?
    owner_type == 'Admin'
  end

  private

  def set_initial_refresh_time
    self.rth_refreshed_at = DateTime.now.change(min: 0, sec: 0)
    self.rtd_refreshed_at = Date.today
    self.core_rth_refreshed_at = DateTime.now.change(min: 0, sec: 0)
    self.core_rtd_refreshed_at = Date.today
  end
end
