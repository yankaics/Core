class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :code
      t.string :name
      t.string :short_name

      t.timestamps
    end

    add_index :organizations, :code, unique: true
  end
end
