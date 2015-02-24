class AddSkipConfirmationToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :skip_confirmation, :boolean, null: false, default: false
  end
end
