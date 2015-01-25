set_fields(:user_email, [:id, :email], [:id, :email, :confirmed_at, :created_at])
set_include(:user_email)

object @user_email
attributes(*fields[:user_email])
