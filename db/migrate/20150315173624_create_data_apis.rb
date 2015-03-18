class CreateDataApis < ActiveRecord::Migration
  def change
    create_table :data_apis do |t|
      t.string :name, null: false
      t.string :path, null: false
      t.string :organization_code

      t.text :schema
      t.string :primary_key, null: false, default: 'id'
      t.text :has

      t.string :database_url
      t.boolean :maintain_schema, null: false, default: true

      t.timestamps
    end

    add_index :data_apis, :name, unique: true
    add_index :data_apis, :path, unique: true
    add_index :data_apis, :organization_code, unique: false
  end
end
