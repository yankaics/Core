object @user

set_fieldset :user, default_fields: [:id, :name, :username, :avatar_url, :cover_photo_url],
                    permitted_fields: User::PUBLIC_ATTRS + User::EMAIL_ATTRS + User::ACCOUNT_ATTRS + User::FB_ATTRS + User::INFO_ATTRS + User::IDENTITY_ATTRS + User::CORE_ATTRS
set_inclusion :user, default_includes: [:emails, :primary_identity, :identities]

set_inclusion_field :user, :emails, :email_ids, class_name: :UserEmail
set_inclusion_field :user, :primary_identity, :primary_identity_id, class_name: :UserIdentity
set_inclusion_field :user, :organization, :organization_code,
                    url: "organizations/#{@user.try(:organization_code)}"
set_inclusion_field :user, :department, :department_code
set_inclusion_field :user, :identities, :identity_ids, class_name: :UserIdentity
set_inclusion_field :user, :organizations, :organization_codes,
                    url: "organizations/#{@user.try(:organization_codes).try(:join, ',')}"
set_inclusion_field :user, :departments, :department_codes

attributes(*fieldset[:user])

extends('extensions/includable_childs', locals: { self_resource: :user })

node :_type do
  :user
end

extends('extensions/meta_data', locals: { self_resource: :user })
