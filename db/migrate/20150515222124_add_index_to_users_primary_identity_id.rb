class AddIndexToUsersPrimaryIdentityId < ActiveRecord::Migration
  def change
    add_index :users, :primary_identity_id, unique: true
  end
end
