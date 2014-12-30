class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.boolean :email_pattern_id, index: true, null: true
      t.integer :user_id, index: true, unique: false, null: true
      t.string :email, index: true, unique: true, null: false
      t.string :organization_code, index: true, unique: false, null: false
      t.integer :identity, null: false, default: 0
      t.string :uid, index: true, unique: false, null: false
      t.string :department_code
      t.string :identity_detail, null: false, default: ''
      t.date :started_at

      t.timestamps
    end
  end
end
