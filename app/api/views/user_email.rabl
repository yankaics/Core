set_fieldset :user_email, default_fields: [:id, :email],
                          permitted_fields: [:id, :email, :confirmed_at, :created_at]
set_inclusion :user_email

object @user_email
attributes(*fieldset[:user_email])

node :type do
  :UserEmail
end
