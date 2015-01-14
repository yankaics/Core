class CreateUserEmails < ActiveRecord::Migration
  def change
    create_table :user_emails do |t|
      t.integer :user_id, index: true, null: false
      t.string :email, index: true, null: false, unique: false
      t.string   :confirmation_token
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at, index: true, null: true, unique: false

      t.timestamps
    end

    add_index :user_emails, :confirmation_token, unique: true
  end
end
