class CreateUserManualValidations < ActiveRecord::Migration
  def change
    create_table :user_manual_validations do |t|
      t.integer :user_id
      t.string :state, null: false, default: 'pending'

      t.timestamps null: false
    end
  end
end
