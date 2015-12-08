class AddPermitPushNotificationsToOAuthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :permit_push_notifications, :boolean, default: false
    add_column :oauth_applications, :permit_email_notifications, :boolean, default: false
    add_column :oauth_applications, :permit_sms_notifications, :boolean, default: false
    add_column :oauth_applications, :permit_fb_notifications, :boolean, default: false
  end
end
