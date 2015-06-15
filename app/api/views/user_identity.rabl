set_fieldset :user_identity, default_fields: [:id, :organization_code, :department_code, :original_department_code, :name, :uid, :email, :identity, :identity_detial, :started_at],
                             permitted_fields: [:id, :organization_code, :department_code, :original_department_code, :organization, :department, :original_department, :name, :uid, :email, :identity, :identity_detial, :started_at]
set_inclusion :user_identity

object @user_identity

attributes(*(fieldset(:user_identity) - inclusion_field(:user_identity).keys))

node :_type do
  :user_identity
end

extends('extensions/meta_data', locals: { self_resource: :user_identity })
