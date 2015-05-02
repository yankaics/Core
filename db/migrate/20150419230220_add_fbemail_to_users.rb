class AddFbemailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :fbemail, :string
    add_index :users, :fbemail

    User.where.not(fbid: nil).find_each do |user|
      next if user.fbemail.present?
      user.fbemail = user.email
      user.save!(validate: false)
    end
  end
end
