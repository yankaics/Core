class Organization < ActiveRecord::Base
  include Codeable
  extend FriendlyId
  friendly_id :code

  has_many :departments, primary_key: :code, foreign_key: :organization_code, dependent: :delete_all
  has_many :email_patterns, primary_key: :code, foreign_key: :organization_code, dependent: :delete_all
  has_many :user_identities, primary_key: :code, foreign_key: :organization_code
  has_many :users, through: :user_identities

  accepts_nested_attributes_for :departments, allow_destroy: true
  accepts_nested_attributes_for :email_patterns, allow_destroy: true

  validates :code, uniqueness: true
  validates :code, :name, :short_name, presence: true
  validates_associated :departments, :email_patterns

  # UserIdentity::IDENTITIES.keys.each do |identity|
  #   define_method identity.to_s.pluralize do
  #   end
  # end

  def self.all_for_select
    all.map { |u| [u.name, u.code] }
  end

  def department_codes
    department_ids
  end

  def departments_for_select
    departments.all.map { |d| [d.name, d.code] }
  end
end
