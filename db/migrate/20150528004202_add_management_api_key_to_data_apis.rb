class AddManagementAPIKeyToDataApis < ActiveRecord::Migration
  def up
    add_column :data_apis, :management_api_key, :string

    DataAPI.find_each do |data_api|
      next if data_api.management_api_key.present?
      data_api.update_column(:management_api_key, SecureRandom.urlsafe_base64(64).gsub(/[^a-zA-Z0-9]/, '0'))
    end

    change_column :data_apis, :management_api_key, :string, null: false
  end

  def down
    remove_column :data_apis, :management_api_key
  end
end
