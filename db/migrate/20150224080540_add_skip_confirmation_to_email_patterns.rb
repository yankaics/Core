class AddSkipConfirmationToEmailPatterns < ActiveRecord::Migration
  def change
    add_column :email_patterns, :skip_confirmation, :boolean, null: false, default: false
  end
end
