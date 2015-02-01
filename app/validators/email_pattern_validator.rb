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
