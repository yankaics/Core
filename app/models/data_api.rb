class DataAPI < ActiveRecord::Base
  attr_accessor :specified_resource_id, :exception
  alias_method :specified_resource_ids, :specified_resource_id
  has_paper_trail class_name: 'DataAPIVersion'

  OWNER_PRIMARY_KEYS = %w(id uuid email uid)

  scope :global, -> { where(organization_code: nil) }
  scope :local, -> { where.not(organization_code: nil) }
  scope :public_accessible, -> { where(public: true, accessible: true) }
  scope :accessible, -> { where(accessible: true) }
  scope :owned_by_user, -> { where(owned_by_user: true) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code

  validates_with DataAPIValidator
  validates :name, :path, :table_name, :management_api_key, presence: true
  validates :name, :path, uniqueness: true
  validates :table_name, uniqueness: true, if: :using_system_database?
  validates :name, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :table_name, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :path, format: { with: /\A[a-z0-9_]+(\/[a-z0-9_]+){0,4}\z/ }
  validates :database_url, format: { with: /\A(postgresql:\/\/)|(mysql:\/\/)|(sqlite3:db\/)/ }, allow_blank: true
  validates :owner_primary_key, presence: true, inclusion: { in: OWNER_PRIMARY_KEYS }, if: :owner?
  validates :owner_foreign_key, presence: true, if: :owner?

  after_initialize :initialize_management_api_key
  after_find :reset_data_model_if_needed

  before_validation :nilify_blanks
  before_validation :save_schema
  before_save :save_schema

  before_update :reset_data_model

  after_create :create_db_table_if_needed
  before_update :update_db_table_if_needed
  after_destroy :drop_db_table_if_needed

  after_update :reset_data_model

  # Get the System API Database URL
  def self.database_url
    return @database_url if @database_url.present?
    if Rails.env.test?
      @database_url = "sqlite3:db/test_api.sqlite3"
    elsif ENV['API_DATABASE_URL'].blank?
      possible_databases = ENV.select { |k| k.match(/(SQL|DATABASE)_.*URL/) }.map { |_, v| v }
      possible_databases.delete(ENV['DATABASE_URL'])
      @database_url = possible_databases.first || ENV['DATABASE_URL']
    else
      @database_url = ENV['API_DATABASE_URL']
    end
  end

  # Find a DataAPI by a resource path
  # TODO: cache the result
  def self.find_by_path(path, include_not_public: false, include_inaccessible: false)
    # scope the collection
    if include_inaccessible
      scoped_collection = DataAPI.all
    else
      scoped_collection = DataAPI.where(accessible: true)
    end

    unless include_not_public
      scoped_collection = scoped_collection.where(public: true)
    end

    # if the resource path might be a specified resource path
    possible_specified_resource_path = path.match(%r{(?<path>.+)\/(?<id>[^\/]+)\z})

    # query the database to find the result
    if possible_specified_resource_path
      data_api = scoped_collection.find_by(
        path: [path, possible_specified_resource_path[:path]]
      )
      data_api.specified_resource_id = possible_specified_resource_path[:id] if \
        data_api.present? && data_api.path != path
    else
      data_api = scoped_collection.find_by(path: path)
    end

    data_api
  end

  def schema
    @schema ||= DataAPI::Schema.new(self[:schema], true)
  end

  def schema=(s)
    @schema = DataAPI::Schema.new(s)
  end

  # Is this API's data owned by users?
  def owner?
    owned_by_user
  end

  # List of columns
  def columns
    return @columns if @columns
    @columns = schema.keys.map(&:to_sym)
  end

  # List of accessible fields
  def fields
    return @fields if @fields
    @fields = columns
    @fields << :id
    @fields &= data_model.columns.map { |c| c.name.to_sym }
    @fields << :owner if owner?
    @fields
  end

  def writable_fields(primary_key: true)
    if primary_key
      return @writable_fields if @writable_fields
      @writable_fields = schema.keys
    else
      return @writable_fields_without_primary_key if @writable_fields_without_primary_key
      @writable_fields_without_primary_key = schema.keys - [self.primary_key]
    end
  end

  def owner_write_permitted_fields(primary_key: true)
    if primary_key
      return @owner_write_permitted_fields if @owner_write_permitted_fields
      @owner_write_permitted_fields = writable_fields(primary_key: true)
      @owner_write_permitted_fields -= [owner_foreign_key]
    else
      return @owner_write_permitted_fields_without_primary_key if @owner_write_permitted_fields_without_primary_key
      @owner_write_permitted_fields_without_primary_key = writable_fields(primary_key: false)
      @owner_write_permitted_fields_without_primary_key -= [owner_foreign_key]
    end
  end

  # List of accessible fields
  def includable_fields
    return @includable_fields if @includable_fields
    @includable_fields = []
    @includable_fields << :owner if owner?
    @includable_fields
  end

  # Is this API using the system database?
  def using_system_database?
    self[:database_url].blank?
  end

  # Is this API using an outer database?
  def using_outer_database?
    self[:database_url].present?
  end

  # Returns all the API data
  def data_api_api_data
    data_model.all
  end

  # Get the database URL of this data API
  # (prefixed with 'get' to separate with the original database_url getter,
  #  which returns nil if the outer database_url for this API is not setted)
  def get_database_url
    self[:database_url].present? ? self[:database_url] : DataAPI.database_url
  end

  # Get the data model of this API Data
  def data_model
    return DataModels.get(name.classify) if DataModels.has?(name.classify)

    DataModels.construct(name.classify,
      database_url: get_database_url,
      table_name: table_name,
      primary_key: primary_key,
      organization_code: organization_code,
      owned_by_user: owned_by_user,
      owner_primary_key: owner_primary_key,
      owner_foreign_key: owner_foreign_key,
      updated_at: updated_at
    )
  end

  def data_count
    data_model.count
  end

  def save_schema
    schema.validate!
    self[:schema] = schema.to_s
  end

  def reset_data_model
    DataModels.remove_if_exists(name.classify)
    begin
      data_model.connection.schema_cache.clear!
      data_model.reset_column_information
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error e
    end
  end

  def reset_data_model_if_needed
    reset_data_model if data_model.try(:updated_at) != updated_at
  end

  def initialize_management_api_key
    return if management_api_key.present?
    self.management_api_key = SecureRandom.urlsafe_base64(64).gsub(/[^a-zA-Z0-9]/, '0')
  end

  def nilify_blanks
    self.organization_code = nil if organization_code.blank?
    self.description = nil if description.blank?
    self.notes = nil if notes.blank?
    self.database_url = nil if database_url.blank?
    self.owner_primary_key = nil if owner_primary_key.blank?
    self.owner_foreign_key = nil if owner_foreign_key.blank?
  end

  def test_update
    db_maintainer = DatabaseMaintainer.new(data_model)

    previous_version = DataAPI.find(id)
    return nil if previous_version.blank?

    old_table_name = previous_version.table_name
    new_table_name = table_name
    old_schema = previous_version.schema
    new_schema = schema

    db_maintainer.update_table(old_table_name, new_table_name, old_schema, new_schema, test_run: true)
  end

  private

  # Database callback operations

  def create_db_table_if_needed
    return unless maintain_schema
    db_maintainer = DatabaseMaintainer.new(data_model)
    db_maintainer.create_table(table_name, schema)
  end

  def update_db_table_if_needed
    return unless maintain_schema
    db_maintainer = DatabaseMaintainer.new(data_model)

    previous_version = DataAPI.find(id)

    old_table_name = previous_version.table_name
    new_table_name = table_name
    old_schema = previous_version.schema
    new_schema = schema

    db_maintainer.update_table(old_table_name, new_table_name, old_schema, new_schema)
  end

  def drop_db_table_if_needed
    return unless maintain_schema
    db_maintainer = DatabaseMaintainer.new(data_model)
    db_maintainer.drop_table table_name
  end
end
