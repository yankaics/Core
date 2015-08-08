class EmailPatternSerializer < ActiveModel::Serializer
  attributes :id, :priority, :organization_code, :corresponded_identity, :email_regexp, :uid_postparser, :department_code_postparser, :started_at_postparser, :identity_detail_postparser, :permit_changing_department_in_group, :permit_changing_department_in_organization, :permit_changing_started_at
  has_one :organization
end
