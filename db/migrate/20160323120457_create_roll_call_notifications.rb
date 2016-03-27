class CreateRollCallNotifications < ActiveRecord::Migration
  def change
    create_table :roll_call_notifications do |t|
      t.integer :user_id
      t.string :organization_code
      t.string :course_code

      t.timestamps null: false
    end
    add_index :roll_call_notifications, :user_id
    add_index :roll_call_notifications, :organization_code
    add_index :roll_call_notifications, :course_code
  end
end
