class UserFacebookSyncJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    user.facebook_sync
  end
end
