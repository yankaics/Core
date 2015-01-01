class Department < ActiveRecord::Base
  include Codeable

  scope :root, -> { where(parent: nil) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code
  has_many :departments, ->(o) { where "departments.organization_code = ?", o.organization_code }, class_name: :Department, primary_key: :code, foreign_key: :parent_code, dependent: :destroy
  belongs_to :parent, ->(o) { where "departments.organization_code = ?", o.organization_code }, class_name: :Department, primary_key: :code, foreign_key: :parent_code
  has_many :user_identities, primary_key: :code, foreign_key: :department_code
  has_many :users, through: :user_identities

  friendly_id :code
  delegate :name, :short_name, to: :parent, prefix: true, allow_nil: true

  validates :code, uniqueness: { scope: :organization_code }
  validates :organization, :code, :name, :short_name, presence: true

  # UserIdentity::IDENTITES.keys.each do |identity|
  #   define_method identity.to_s.pluralize do
  #   end
  # end
end
