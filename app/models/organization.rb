class Organization < ActiveRecord::Base
  include Codeable

  has_many :departments, primary_key: :code, foreign_key: :organization_code, dependent: :delete_all
  has_many :email_patterns, primary_key: :code, foreign_key: :organization_code, dependent: :delete_all
  # has_many :users

  accepts_nested_attributes_for :departments, allow_destroy: true
  accepts_nested_attributes_for :email_patterns, allow_destroy: true

  validates :code, uniqueness: true
  validates :code, :name, :short_name, presence: true
  validates_associated :departments, :email_patterns
end
