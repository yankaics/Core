class DataAPI < ActiveRecord::Base
  scope :global, -> { where(organization_code: nil) }
  scope :local, -> { where.not(organization_code: nil) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code

  serialize :schema

  validates :name, :path, presence: true
end
