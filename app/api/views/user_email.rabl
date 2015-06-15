set_fieldset :user_email, default_fields: [:id, :email],
                          permitted_fields: [:id, :email, :confirmed_at, :created_at]
set_inclusion :user_email

object @user_email

attributes(*(fieldset(:user_email) - inclusion_field(:user_email).keys))

node :_type do
  :user_email
end

extends('extensions/meta_data', locals: { self_resource: :user_email })
