class EmailPattern < ActiveRecord::Base
  include Serializable

  default_scope { order('priority ASC') }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code
  has_many :user_identifies

  enum corresponded_identity: UserIdentity::IDENTITIES

  validates :priority, :organization, :corresponded_identity, :email_regexp, presence: true
  validates_with EmailPatternValidator

  def self.identify(email)
    all.each do |pattern|
      matchdata = email.match(/#{pattern.email_regexp}/)

      if matchdata
        matchdata_hash = matchdata.to_hash
        matchdata_hash[:email_pattern_id] = pattern.id
        matchdata_hash[:email] = email
        matchdata_hash[:organization_code] = pattern.organization_code
        matchdata_hash[:identity] = pattern.corresponded_identity
        matchdata_hash[:uid] = matchdata.to_s unless matchdata_hash.key?(:uid)

        matchdata_hash[:permit_changing_department_in_group] = pattern.permit_changing_department_in_group
        matchdata_hash[:permit_changing_department_in_organization] = pattern.permit_changing_department_in_organization
        matchdata_hash[:permit_changing_started_at] = pattern.permit_changing_started_at
        matchdata_hash[:skip_confirmation] = pattern.skip_confirmation

        return parse_email_matches(matchdata_hash, pattern)
      end
    end
    return nil
  end

  def self.parse_email_matches(hash, pattern)
    cxt = V8::Context.new

    { uid:              :uid_postparser,
      identity_detail:  :identity_detail_postparser,
      department_code:  :department_code_postparser,
      started_at:       :started_at_postparser
    }.each do |data_name, postparser_name|
      unless pattern[postparser_name].blank?
        hash[data_name].gsub!(/[^A-Za-z0-9 \-_\.]/, '')
        cxt['n'] = hash[data_name]
        hash[data_name] = cxt.eval(pattern[postparser_name])
      end

      if data_name == :started_at
        hash[data_name] = Time.at(hash[data_name].to_i)
      else
        hash[data_name] = hash[data_name].to_s
      end
    end

    hash[:original_department_code] = hash[:department_code]

    return hash
  end
  private_class_method :parse_email_matches
end
