class UserExternalImageDownloadJob < ActiveJob::Base
  queue_as :image

  def perform(user)
    user.download_external_avatar! if !user.avatar_local &&
                                      user.external_avatar_url.present?
    user.download_external_cover_photo! if !user.cover_photo_local &&
                                           user.external_cover_photo_url.present?
  end
end
