class AddFbFriendsToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :fb_friends, :text
  end
end
