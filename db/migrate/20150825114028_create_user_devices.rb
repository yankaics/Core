class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.integer :user_id
      t.string :uuid
      t.integer :type, limit: 1
      t.string :name
      t.text :device_id

      t.timestamps null: false
    end

    add_index :user_devices, :user_id
    add_index :user_devices, :uuid
    add_index :user_devices, :type
  end
end
