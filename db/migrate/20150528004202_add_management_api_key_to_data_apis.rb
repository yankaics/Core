class AddManagementAPIKeyToDataApis < ActiveRecord::Migration
  def up
    add_column :data_apis, :management_api_key, :string

    DataAPI.find_each do |data_api|
      data_api.save!
    end

    change_column :data_apis, :management_api_key, :string, null: false
  end

  def down
    remove_column :data_apis, :management_api_key
  end
end
