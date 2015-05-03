class AddAttributesToDataAPI < ActiveRecord::Migration
  def change
    add_column :data_apis, :accessible, :boolean, null: false, default: false
    add_index :data_apis, :accessible
    add_column :data_apis, :public, :boolean, null: false, default: false
    add_index :data_apis, :public
    add_column :data_apis, :owned_by_user, :boolean, null: false, default: false
    add_index :data_apis, :owned_by_user
    add_column :data_apis, :owner_primary_key, :string
    add_column :data_apis, :owner_foreign_key, :string
  end
end
