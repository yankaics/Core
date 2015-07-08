class ChangeUsersFbtokenToText < ActiveRecord::Migration
  def up
    change_column :users, :fbtoken, :text
  end

  def down
    change_column :users, :fbtoken, :string
  end
end
