class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable,
         :authentication_keys => [:username]

  validates_uniqueness_of :username, :email
end
