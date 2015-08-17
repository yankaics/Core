module FacebookSyncable
  extend ActiveSupport::Concern

  def facebook_sync
    get_info_connection = HTTParty.get(
      <<-eos.squish.delete(' ')
        https://graph.facebook.com/me?
          fields=#{FacebookService.app_me_info_fields_string}&
          access_token=#{fbtoken}&
          locale=#{I18n.locale}
        eos
    )

    return false unless get_info_connection.code == 200

    info = get_info_connection.parsed_response
    info = JSON.parse(info) if info.is_a?(String)

    return false if info['id'].blank?

    info.each_pair do |k, v|
      case k
      when 'name'
        self.name = v
      when 'picture'
        self.external_avatar_url = v['data']['url']
      when 'cover'
        self.external_cover_photo_url = v['source']
      when 'gender'
        v = 'male' if v.match('男')
        v = 'female' if v.match('女')
        data.gender = v
      when 'link'
      when 'friends'
        data.fb_friends = v.except('paging')
      when 'birthday'
        match = v.match(/(?<month>\d{2})\/(?<day>\d{2})\/(?<year>\d{4})?/)
        data.birth_year = match[:year].to_i if match[:year]
        data.birth_month = match[:month].to_i if match[:month]
        data.birth_day = match[:day].to_i if match[:day]
      when 'age_range'
      when 'devices'
        data.fb_devices = v
      end
    end

    self.save!

    download_external_avatar! if !avatar_local &&
                                 external_avatar_url.present?
    download_external_cover_photo! if !cover_photo_local &&
                                      external_cover_photo_url.present?
  end
end
