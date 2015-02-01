class UserEmailValidator < ActiveModel::Validator
  def validate(record)
    if UserEmail.confirmed.where.not(id: record.id).exists?(email: record.email)
      record.errors[:base] << "This email is already being used."
    end
  end
end
