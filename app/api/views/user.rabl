set_fields(:user, [:id, :name, :username, :avatar_url, :cover_photo_url])
set_include(:user)

object @user
attributes(*@fields[:user])

if @include[:user].include?(:organization)
  child :organization do
    extends('organization')
  end
else
  node :organization do |u|
    u.organization_code
  end
end if @fields[:user].include?(:organization)
