module OmniauthCallable
  extend ActiveSupport::Concern

  module ClassMethods
    def from_facebook(auth)
      get_info_connection = HTTParty.get(
        <<-eos.squish.delete(' ')
          https://graph.facebook.com/me?
            fields=id,name,link,picture.height(500).width(500),cover,
                   devices,friends&
            access_token=#{auth[:credentials][:token]}&
            locale=#{I18n.locale}
          eos
      )
      info = get_info_connection.parsed_response

      user = where(fbid: auth[:uid]).first_or_create! do |new_user|
        new_user.email = auth[:info][:email]
        new_user.password = Devise.friendly_token[0, 20]
        new_user.name = auth[:info][:name]
        new_user.gender = auth[:extra][:raw_info][:gender]
        name = info[:name]
        new_user.name = name if name
      end

      user.confirm!

      user.update_attributes(
        fbtoken: auth[:credentials][:token],
        avatar_url: info[:picture] && info[:picture][:data] && info[:picture][:data][:url]
      )

      return user
    end
  end
end
