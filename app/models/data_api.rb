class DataAPI < ActiveRecord::Base
  attr_accessor :single_data_id
  has_paper_trail class_name: 'DataAPIVersion'

  COLUMN_TYPES = %w(string integer float boolean text datetime)
  OWNER_PRIMARY_KEYS = %w(id uuid email uid)

  scope :global, -> { where(organization_code: nil) }
  scope :local, -> { where.not(organization_code: nil) }
  scope :public_accessible, -> { where(public: true, accessible: true) }
  scope :accessible, -> { where(accessible: true) }
  scope :owned_by_user, -> { where(owned_by_user: true) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code

  validates_with DataAPIValidator
  validates :name, :path, presence: true
  validates :name, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :path, format: { with: /\A[a-z0-9_]+(\/[a-z0-9_]+){0,4}\z/ }
  validates :database_url, format: { with: /\A(postgresql:\/\/)|(mysql:\/\/)|(sqlite3:db\/)/ }, allow_blank: true
  validates :owner_primary_key, presence: true, inclusion: { in: OWNER_PRIMARY_KEYS }, if: :has_owner?
  validates :owner_foreign_key, presence: true, if: :has_owner?

  after_find :reset_data_model_if_needed, :inspect_data_model
  before_validation :save_schema
  before_save :save_schema
  before_validation :check_organization_code
  after_create :create_db_table
  before_update :reset_data_model_const, :change_db_table
  after_update :reset_data_model_column_information
  after_destroy :drop_db_table

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

  def self.find_by_path(path, private: false)
    singular_path = path.match(/(?<path>.+)\/(?<id>[^\/]+)\z/)
    if singular_path
      if private
        data_api = DataAPI.find_by(path: [path, singular_path[:path]], accessible: true)
      else
        data_api = DataAPI.find_by(path: [path, singular_path[:path]], public: true, accessible: true)
      end
      data_api.single_data_id = singular_path[:id] if data_api.present? && data_api.path != path
    else
      if private
        data_api = DataAPI.find_by(path: path, accessible: true)
      else
        data_api = DataAPI.find_by(path: path, public: true, accessible: true)
      end
    end
    data_api
  end

  def columns
    schema.keys
  end

  def schema=(s)
    @schema = DataAPI::Schema.new(s)
  end

  def schema
    @schema ||= DataAPI::Schema.new(self[:schema], true)
  end

  def save_schema
    schema.validate!
    self[:schema] = schema.to_s
  end

  # Is this API using the system database?
  def using_system_database?
    self[:database_url].blank?
  end

  # Is this API using an outer database?
  def using_outer_database?
    self[:database_url].present?
  end

  # Get the database URL of this data API
  # (prefixed with 'get' to separate with the original database_url getter,
  #  which returns nil if the outer database_url for this API is not setted)
  def get_database_url
    self[:database_url].present? ? self[:database_url] : DataAPI.database_url
  end

  # Get the database table name of this data API
  def table_name
    self[:table_name].present? ? self[:table_name] : name
  end

  def data_model
    return DataModels.get(name.classify) if DataModels.has?(name.classify)

    DataModels.construct(name.classify,
      database_url: get_database_url,
      table_name: table_name,
      organization_code: organization_code,
      owned_by_user: owned_by_user,
      owner_primary_key: owner_primary_key,
      owner_foreign_key: owner_foreign_key,
      updated_at: updated_at
    )
  end

  def data_api_api_data
    data_model.all
  end

  def reset_data_model_const
    DataModels.remove_if_exists(name.classify)
    begin
      data_model.establish_connection get_database_url
      data_model.connection.schema_cache.clear!
      data_model.reset_column_information
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error e
    end
  end

  def reset_data_model_if_needed
    reset_data_model_const if data_model.try(:updated_at) != updated_at
  end

  def reset_data_model_column_information
    data_model.reset_column_information
  end

  def inspect_data_model
    data_model.inspect
  end

  def create_db_table
    return unless maintain_schema
    migration = new_migration

    migration.create_table name do |t|
      # t.string :uid, null: false

      schema.each do |k, v|
        t.send(v['type'], k)
      end

      # t.timestamps
    end

    # migration.add_index name, :uid, unique: true
  end

  def change_db_table
    return unless maintain_schema
    migration = new_migration
    previous_version = DataAPI.find(id)
    old_table_name = previous_version.name
    current_table_name = name

    if current_table_name != old_table_name
      migration.rename_table old_table_name, current_table_name
    end

    old_columns = Hash[previous_version.schema.map { |k, v| [v['uuid'], v.merge('name' => k)] }]
    current_columns = Hash[schema.map { |k, v| [v['uuid'], v.merge('name' => k)] }]

    deleted_columns = {}

    old_columns.each do |k, v|
      deleted_columns[k] = v unless current_columns.key?(k)
    end

    deleted_columns.each do |_uuid, column|
      migration.remove_column name, column['name']
    end

    new_columns = {}

    current_columns.each do |k, v|
      new_columns[k] = v unless old_columns.key?(k)
    end

    new_columns.each do |_uuid, column|
      migration.add_column name, column['name'], column['type']
    end

    renamed_columns = {}

    current_columns.each do |k, v|
      renamed_columns[k] = v if old_columns[k].present? && v['name'] != old_columns[k]['name']
    end

    renamed_columns.each do |uuid, _column|
      migration.rename_column name, old_columns[uuid]['name'], current_columns[uuid]['name']
    end

    reset_data_model_const
  end

  def drop_db_table
    migration = new_migration
    migration.drop_table name
  end

  def has_owner?
    owned_by_user
  end

  private

  def new_migration
    migration = ActiveRecord::Migration.new
    migration.instance_exec(get_database_url) do |db_url|
      @db_url = db_url

      def connection
        begin
          DataAPI::DataModel.establish_connection @db_url
        rescue ActiveRecord::AdapterNotSpecified
        end
        DataAPI::DataModel.connection
      end
    end
    migration
  end

  def check_organization_code
    self.organization_code = nil if organization_code.blank?
  end
end
