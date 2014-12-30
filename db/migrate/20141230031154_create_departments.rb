class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :organization_code, null: false, index: true, unique: false
      t.string :code, null: false, index: true, unique: false
      t.string :name, null: false
      t.string :short_name, null: false
      t.string :parent_code, null: true, index: true, unique: false

      t.timestamps
    end

    add_index :departments, :organization_code, unique: false
  end
end
