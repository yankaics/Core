class EmailPatternValidator < ActiveModel::Validator
  def validate(record)
    begin
      /#{record.email_regexp}/
    rescue RegexpError
      record.errors[:base] << "The Regexp is not vaild!"
    end
    cxt = V8::Context.new
    cxt['n'] = '01'
    [:uid_postparser, :department_code_postparser, :identity_detail_postparser, :started_at_postparser].each do |postparser|
      begin
        cxt.eval(record[postparser])
      rescue V8::Error
        record.errors[:base] << "The Regexp is not vaild!"
      end
    end
  end
end

class EmailPattern < ActiveRecord::Base
  default_scope { order('priority ASC') }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code
  has_many :user_identifies

  enum corresponded_identity: UserIdentity::IDENTITES

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

        return eval_email_matches(matchdata_hash, pattern)
      end
    end
    return nil
  end

  def self.eval_email_matches(hash, pattern)
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

    return hash
  end
  private_class_method :eval_email_matches
end
