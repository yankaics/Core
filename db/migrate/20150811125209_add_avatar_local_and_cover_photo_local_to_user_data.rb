class AddAvatarLocalAndCoverPhotoLocalToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :avatar_local, :boolean, null: false, default: false
    add_column :user_data, :cover_photo_local, :boolean, null: false, default: false
  end
end
