class CreateServiceNavigations < ActiveRecord::Migration
  def change
    create_table :service_navigations do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.string :color
      t.attachment :icon
      t.attachment :background_image
      t.attachment :background_pattern
      t.string :description
      t.text :introduction
      t.integer :order, null: false, default: 100
      t.boolean :visible, null: false, default: false
      t.boolean :opened, null: false, default: false
      t.boolean :show_on_index, null: false, default: false
      t.boolean :show_on_mobile_index, null: false, default: false
      t.integer :index_order, null: false, default: 100
      t.integer :index_size, null: false, default: 1

      t.timestamps null: false
    end
  end
end
