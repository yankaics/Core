class AddAllowDirectDataAccessToOAuthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :allow_direct_data_access, :boolean, null: false, default: false
  end
end
