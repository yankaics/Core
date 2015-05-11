class AddOwnerWritableToDataApis < ActiveRecord::Migration
  def change
    add_column :data_apis, :owner_writable, :boolean, null: false, default: false
    add_index :data_apis, :owner_writable
  end
end
