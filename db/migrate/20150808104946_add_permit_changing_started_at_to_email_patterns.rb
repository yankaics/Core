class AddPermitChangingStartedAtToEmailPatterns < ActiveRecord::Migration
  def change
    add_column :email_patterns, :permit_changing_started_at, :boolean, null: false, default: false
  end
end
