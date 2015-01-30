set_fields(:user_identity, [:id, :organization_code, :department_code, :uid, :email, :identity, :identity_detial, :started_at], [:id, :organization_code, :department_code, :uid, :email, :identity, :identity_detial, :started_at])
set_include(:user_identity)

object @user_identity
attributes(*fields[:user_identity])
