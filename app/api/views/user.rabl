user_fields = @user_fields.presence || [:id, :name, :username, :avatar_url, :cover_photo_url, :gender]
user_include = @user_include.presence || []
organization_fields = @organization_fields.presence || [:code, :name]

object @user
attributes(*user_fields)

if user_include.include?(:organization)
  child :organization do
    attributes(*organization_fields)
  end
else
  node :organization do |u|
    u.organization_code
  end
end if user_fields.include?(:organization)

