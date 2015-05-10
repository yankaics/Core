class AddTableNameToDataApis < ActiveRecord::Migration
  def change
    add_column :data_apis, :table_name, :string

    DataAPI.find_each do |data_api|
      next if data_api.table_name.present?
      data_api.update_column(:table_name, data_api.name)
    end

    add_index :data_apis, :table_name, unique: true
    change_column :data_apis, :table_name, :string, null: false
  end
end
