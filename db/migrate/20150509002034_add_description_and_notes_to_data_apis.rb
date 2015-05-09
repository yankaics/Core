class AddDescriptionAndNotesToDataApis < ActiveRecord::Migration
  def change
    add_column :data_apis, :description, :string
    add_column :data_apis, :notes, :text
  end
end
