class AddAvatarCropDataToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :avatar_crop_x, :integer
    add_column :user_data, :avatar_crop_y, :integer
    add_column :user_data, :avatar_crop_w, :integer
    add_column :user_data, :avatar_crop_h, :integer
  end
end
