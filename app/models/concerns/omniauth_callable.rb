module OmniauthCallable
  extend ActiveSupport::Concern

  included do
    attr_accessor :from
  end

  module ClassMethods
    def from_facebook(auth, foreign_app: false, whitelisted_app: false)
      # reject Facebook users without verified email
      return false if auth[:info][:email].blank? || auth[:info][:name].blank?

      # find of create user by the following order:
      # first, find the user using the fbid,
      # second, find the user using their fbemail,
      # third, find the user with the email same as fbemail (where(email: ...).first...),
      # and for last, create that user (where(email: ...)...._or_create!)
      user = (auth[:uid].present? && where(fbid: auth[:uid]).first) ||
             where(fbemail: auth[:info][:email]).first ||
             where(email: auth[:info][:email]).first_or_create! do |new_user|
               new_user.fbid = auth[:uid]
               new_user.fbemail = auth[:info][:email]
               new_user.password = Devise.friendly_token[0, 20]
               new_user.name = auth[:info][:name]
               new_user.external_avatar_url = auth[:extra][:raw_info][:picture][:data][:url] if auth[:extra][:raw_info][:picture]
               new_user.external_cover_photo_url = auth[:extra][:raw_info][:cover][:source] if auth[:extra][:raw_info][:cover]
             end

      # confirm the user since their email has already verified by Facebook
      user.confirm!

      # update the user's email if they are using an temporary email
      user.update_attributes(email: auth[:info][:email]) if user.email.ends_with?('@dev.null')

      if foreign_app
        user.from = 'foreign_facebook'
      else
        user.from = 'facebook'
        user.update_attributes(
          fbid: auth[:uid],
          fbemail: auth[:info][:email],
          fbtoken: auth[:credentials][:token]
        )
      end

      if whitelisted_app
        user.from = 'facebook' if user.from == 'foreign_facebook'
      end

      user.save

      # sync other fields from facebook
      UserFacebookSyncJob.perform_later(user) unless foreign_app

      return user
    end
  end
end
