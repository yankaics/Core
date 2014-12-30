class CreateUserData < ActiveRecord::Migration
  def change
    create_table :user_data do |t|
      t.integer :user_id, null: false, index: true, unique: true
      t.integer :gender, limit: 1, null: false, default: 0
      t.integer :birth_year
      t.integer :birth_month, limit: 1
      t.integer :birth_day, limit: 1
      t.string :url, null: false, default: ""
      t.text :brief, null: false, default: ""
      t.text :motto, null: false, default: ""

      t.timestamps
    end
  end
end
