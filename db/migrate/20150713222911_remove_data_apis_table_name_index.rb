class RemoveDataApisTableNameIndex < ActiveRecord::Migration
  def change
    remove_index :data_apis, name: :index_data_apis_on_table_name
  end
end
