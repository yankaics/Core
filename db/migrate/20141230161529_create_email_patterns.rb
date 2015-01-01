class CreateEmailPatterns < ActiveRecord::Migration
  def change
    create_table :email_patterns do |t|
      t.integer :priority, index: true, unique: false, limit: 3, default: 100, null: false
      t.string :organization_code, index: true, unique: false, null: false
      t.integer :corresponded_identity, limit: 1, null: false
      t.string :email_regexp, null: false

      t.text :uid_postparser
      t.text :department_code_postparser
      t.text :started_at_postparser
      t.text :identity_detail_postparser

      t.string :permit_changing_department_in_group, null: false, default: false

      t.timestamps
    end
  end
end
