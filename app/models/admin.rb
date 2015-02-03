class Admin < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :trackable, :lockable,
         :authentication_keys => [:username]

  has_many :oauth_applications, class_name: 'Doorkeeper::Application', as: :owner
  belongs_to :organization, primary_key: :code, foreign_key: :scoped_organization_code

  validates_uniqueness_of :username, :email

  class << self
    # Used in ActiveAdmin to save the current_admin in this class on
    # before_action, and access it everywhere
    attr_accessor :current_admin
  end

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
