class DataAPI::DataModel < ActiveRecord::Base
  establish_connection DataAPI.database_url
  self.abstract_class = true
  self.primary_key = :id
  self.inheritance_column = nil

  cattr_accessor :database_url, :organization_code, :updated_at,
                 :owned_by_user, :owner_primary_key, :owner_foreign_key

  # Sets the owner relation in needed
  def self.set_owner_relation
    if owned_by_user
      case owner_primary_key
      when 'id'
        belongs_to :owner, class_name: User, primary_key: :id, foreign_key: owner_foreign_key
      when 'uuid'
        belongs_to :owner, class_name: User, primary_key: :uuid, foreign_key: owner_foreign_key
      when 'email'
        belongs_to :owner, class_name: User, primary_key: :email, foreign_key: owner_foreign_key
      when 'uid'
        belongs_to :owner_identity, ->(o) { where(organization_code: o.class.organization_code) },
                   class_name: UserIdentity, primary_key: :uid, foreign_key: owner_foreign_key
        has_one :owner, class_name: :User, through: :owner_identity, source: :user
      end
    end
  end

  # Try to establish the database connection
  def self.test_db_connection
    remove_connection
    establish_connection database_url
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error e
  end
end
