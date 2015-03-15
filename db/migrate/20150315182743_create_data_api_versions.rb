class CreateDataApiVersions < ActiveRecord::Migration
  def change
    create_table :data_api_versions do |t|
      t.integer  :item_id,   null: false
      t.string   :item_type, null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object
      t.datetime :created_at
    end
    add_index :data_api_versions, [:item_id, :item_type], unique: false
  end
end
