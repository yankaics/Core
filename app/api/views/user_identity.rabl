set_fieldset :user_identity, default_fields: [:id, :organization_code, :department_code, :original_department_code, :name, :uid, :email, :identity, :identity_detial, :started_at],
                             permitted_fields: [:id, :organization_code, :department_code, :original_department_code, :organization, :department, :original_department, :name, :uid, :email, :identity, :identity_detial, :started_at]
set_inclusion :user_identity

object @user_identity
attributes(*fieldset[:user_identity])

node :type do
  :UserIdentity
end
