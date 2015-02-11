class AddKeyToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :key,        :string
    add_column :departments, :parent_key, :string

    add_index :departments, :key,        unique: true
    add_index :departments, :parent_key, unique: false

    reversible do |dir|
      dir.up do
        Department.find_each(&:save!)
      end
    end
  end
end
