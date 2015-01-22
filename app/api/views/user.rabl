set_fields(:user, [:id, :name, :username, :avatar_url, :cover_photo_url])
set_include(:user)

object @user
attributes(*@fields[:user])

node :primary_identity do
  partial('user_identity', object: @user.primary_identity)
end if @fields[:user].include?(:primary_identity)

extends('extensions/includable_child', locals: { self_resource: :user, resource: :organization, unicode: :organization_code })
extends('extensions/includable_child', locals: { self_resource: :user, resource: :department, unicode: :department_code })
