class AddPermitChangingStartedAtToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :permit_changing_started_at, :boolean, null: false, default: false
  end
end
