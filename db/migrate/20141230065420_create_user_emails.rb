class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails do |t|
      t.integer :user_id, index: true, null: false
      t.string :email, index: true, null: false, unique: false
      t.datetime :confirmed_at, index: true, null: true, unique: false

      t.timestamps
    end
  end
end
