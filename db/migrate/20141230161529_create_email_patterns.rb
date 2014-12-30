class CreateEmailPatterns < ActiveRecord::Migration
  def change
    create_table :email_patterns do |t|
      t.integer :priority, index: true, unique: false, limit: 1, default: 100, null: false
      t.string :organization_code, index: true, unique: false, null: false
      t.integer :corresponded_identity, limit: 1, null: false
      t.string :email_regexp, null: false

      t.string :uid_postparser
      t.string :department_code_postparser
      t.string :started_at_postparser
      t.string :identity_detail_postparser

      t.timestamps
    end
  end
end
