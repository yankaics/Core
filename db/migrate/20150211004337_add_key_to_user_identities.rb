class AddKeyToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :key,                     :string
    add_column :user_identities, :department_key,          :string
    add_column :user_identities, :original_department_key, :string

    add_index :user_identities, :key,                     unique: true
    add_index :user_identities, :department_key,          unique: false
    add_index :user_identities, :original_department_key, unique: false

    reversible do |dir|
      dir.up do
        UserIdentity.find_each(&:save!)
      end
    end
  end
end
