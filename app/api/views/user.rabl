set_fields(:user, [:id, :name, :username, :avatar_url, :cover_photo_url])
set_include(:user)

object @user
attributes(*fields[:user])

extends('extensions/includable_child', locals: { self_resource: :user, resource: :emails, model: :user_email, included: true })

extends('extensions/includable_child', locals: { self_resource: :user, resource: :primary_identity, model: :user_identity, included: true })
extends('extensions/includable_child', locals: { self_resource: :user, resource: :organization, unicode: :organization_code })
extends('extensions/includable_child', locals: { self_resource: :user, resource: :department, unicode: :department_code })

extends('extensions/includable_child', locals: { self_resource: :user, resource: :identities, model: :user_identity, included: true })
extends('extensions/includable_child', locals: { self_resource: :user, resource: :organizations, unicode: :organization_codes })
extends('extensions/includable_child', locals: { self_resource: :user, resource: :departments, unicode: 'department_codes' })
