class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :rememberable, :trackable, :lockable,
         :authentication_keys => [:username]

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  belongs_to :organization, primary_key: :code, foreign_key: :scoped_organization_code

  validates_uniqueness_of :username, :email

  def root?
    scoped_organization_code.blank?
  end

  def scoped?
    !scoped_organization_code.blank?
  end

  def admins
    Admin.where(id: id)
  end
end
