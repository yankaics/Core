class RenameDevicesToFbDevicesForUserData < ActiveRecord::Migration
  def change
    rename_column :user_data, :devices, :fb_devices
  end
end
