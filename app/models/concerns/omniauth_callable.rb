module OmniauthCallable
  extend ActiveSupport::Concern

  included do
    attr_accessor :from
  end

  module ClassMethods
    def from_facebook(auth)
      # maybe the user is comed from another app
      if auth[:uid].blank?
        get_info_connection = HTTParty.get(
          <<-eos.squish.delete(' ')
            https://graph.facebook.com/me?
              fields=id,name,link,picture.height(500).width(500),cover&
              access_token=#{auth[:credentials][:token]}&
              locale=#{I18n.locale}
            eos
        )
      # or else
      else
        get_info_connection = HTTParty.get(
          <<-eos.squish.delete(' ')
            https://graph.facebook.com/me?
              fields=id,name,link,picture.height(500).width(500),cover,
                     devices,friends&
              access_token=#{auth[:credentials][:token]}&
              locale=#{I18n.locale}
            eos
        )
      end
      info = get_info_connection.parsed_response
      info = JSON.parse(info) if info.is_a?(String)

      return false if auth[:info][:email].blank? || auth[:info][:name].blank?

      user = (auth[:uid].present? && where(fbid: auth[:uid]).first) ||
             where(fbemail: auth[:info][:email]).first ||
             where(email: auth[:info][:email]).first_or_create! do |new_user|
               new_user.fbemail = auth[:info][:email]
               new_user.fbid = auth[:uid]
               new_user.password = Devise.friendly_token[0, 20]
               new_user.name = auth[:info][:name]
               info_name = info['name']
               new_user.name = info_name if info_name
             end

      user.confirm!

      user.update_columns(email: auth[:info][:email]) if user.email.ends_with?('@dev.null')

      # maybe the user is comed from another app
      if auth[:uid].blank?
        user.from = 'foreign_facebook'
        user.update_attributes(
          external_avatar_url: info['picture'] && info['picture']['data'] && info['picture']['data']['url'],
          external_cover_photo_url: info['cover'] && info['cover']['source']
        )

        user.data.update_attributes(
          gender: auth[:extra][:raw_info][:gender]
        )
      # or else
      else
        user.from = 'facebook'
        user.update_attributes(
          fbid: auth[:uid],
          fbemail: auth[:info][:email],
          fbtoken: auth[:credentials][:token],
          external_avatar_url: info['picture'] && info['picture']['data'] && info['picture']['data']['url'],
          external_cover_photo_url: info['cover'] && info['cover']['source']
        )

        user.data.update_attributes(
          gender: auth[:extra][:raw_info][:gender],
          devices: info['devices'],
          fb_friends: info['friends']
        )
      end

      return user
    end
  end
end
