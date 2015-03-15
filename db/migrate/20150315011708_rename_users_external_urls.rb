class RenameUsersExternalUrls < ActiveRecord::Migration
  def change
    rename_column :users, :avatar_url, :external_avatar_url
    rename_column :users, :cover_photo_url, :external_cover_photo_url
  end
end
