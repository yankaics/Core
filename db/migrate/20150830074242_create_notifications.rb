class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :uuid, null: false
      t.integer :user_id
      t.integer :application_id
      t.string :subject
      t.text :message
      t.string :url
      t.text :payload
      t.datetime :checked_at
      t.datetime :clicked_at
      t.boolean :push, null: false, default: false
      t.datetime :pushed_at
      t.boolean :email, null: false, default: false
      t.datetime :emailed_at
      t.boolean :sms, null: false, default: false
      t.datetime :sms_sent_at
      t.boolean :fb, null: false, default: false
      t.datetime :fb_sent_at

      t.timestamps null: false
    end
    add_index :notifications, :uuid, unique: true
    add_index :notifications, :user_id
    add_index :notifications, :checked_at
    add_index :notifications, :clicked_at
    add_index :notifications, :push
    add_index :notifications, :pushed_at
    add_index :notifications, :email
    add_index :notifications, :emailed_at
    add_index :notifications, :sms
    add_index :notifications, :sms_sent_at
    add_index :notifications, :fb
    add_index :notifications, :fb_sent_at
  end
end
