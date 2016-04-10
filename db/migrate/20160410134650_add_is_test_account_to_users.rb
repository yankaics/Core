class AddIsTestAccountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_test_account, :boolean, default: false, null: false
  end
end
