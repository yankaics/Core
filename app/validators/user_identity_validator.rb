class UserIdentityValidator < ActiveModel::Validator
  def validate(record)
    # record.department = record.organization.departments.find_by(code: record.department_code) if record.department_code_changed?
    if record.department.presence || record.department_code.presence
      record.errors[:base] << "Illegal department." if record.organization_code != record.department.organization_code
      return if record.permit_changing_department_in_organization
      return unless record.original_department_code.presence
      if record.permit_changing_department_in_group
        record.errors[:base] << "Changing the department to a different group from the original one is not permitted for this identity." if record.department.group != record.original_department.group
      elsif record.department_code != record.original_department_code
        record.errors[:base] << "Changing the department against the original one is not permitted for this identity."
      end
    end
  end
end
