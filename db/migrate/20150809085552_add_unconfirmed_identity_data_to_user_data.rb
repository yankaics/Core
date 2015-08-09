class AddUnconfirmedIdentityDataToUserData < ActiveRecord::Migration
  def change
    add_column :user_data, :unconfirmed_organization_code, :string
    add_column :user_data, :unconfirmed_department_code, :string
    add_column :user_data, :unconfirmed_started_year, :string
  end
end
