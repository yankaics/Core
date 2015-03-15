class CreateDataApis < ActiveRecord::Migration
  def change
    create_table :data_apis do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.string :organization_code
      t.text :schema

      t.timestamps
    end

    add_index :data_apis, :name, unique: true
    add_index :data_apis, :path, unique: true
    add_index :data_apis, :organization_code, unique: false
  end
end
