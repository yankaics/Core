class DataAPI < ActiveRecord::Base
  attr_accessor :single_data_id
  has_paper_trail class_name: 'DataAPIVersion'

  COLUMN_TYPES = %w(string integer float boolean text datetime)
  OWNER_PRIMARY_KEYS = %w(id uuid email uid)

  scope :global, -> { where(organization_code: nil) }
  scope :local, -> { where.not(organization_code: nil) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code

  serialize :schema, Hash

  validates_with DataAPIValidator
  validates :name, :path, presence: true
  validates :name, format: { with: /\A[a-z][a-z0-9_]*\z/ }
  validates :path, format: { with: /\A[a-z0-9_]+(\/[a-z0-9_]+){0,4}\z/ }
  validates :database_url, format: { with: /\A(postgresql:\/\/)|(mysql:\/\/)|(sqlite3:db\/)/ }, allow_blank: true
  validates :owner_primary_key, presence: true, inclusion: { in: OWNER_PRIMARY_KEYS }, if: :has_owner?
  validates :owner_foreign_key, presence: true, if: :has_owner?

  after_find :reset_data_model_if_needed, :inspect_data_model
  before_validation :stringify_schema_keys, :remove_blank_columns, :generate_uuid_for_new_columns, :set_type_for_new_columns, :check_organization_code
  after_create :create_db_table
  before_update :reset_data_model_const, :change_db_table
  after_destroy :drop_db_table

  def self.database_url
    return @database_url if @database_url.present?
    if Rails.env.test?
      @database_url = "sqlite3:db/test_api.sqlite3"
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

  module Models
  end

  class Data < ActiveRecord::Base
    cattr_accessor :model

    def self.column_names(*args, &block)
      model.column_names(*args, &block)
    end

    def self.connection(*args, &block)
      model.connection(*args, &block)
    end

    def self.quoted_table_name(*args, &block)
      model.quoted_table_name(*args, &block)
    end

    def self.primary_key(*args, &block)
      model.primary_key(*args, &block)
    end

    def self.human_attribute_name(*args, &block)
      model.human_attribute_name(*args, &block)
    end

    def self.content_columns(*args, &block)
      model.content_columns(*args, &block)
    end

    def self.find_by_id(*args, &block)
      model.find_by_id(*args, &block)
    end

    def self.transaction(*args, &block)
      model.transaction(*args, &block)
    end

    def self.import(*args, &block)
      model.import(*args, &block)
    end
  end

  class Model < ActiveRecord::Base
    establish_connection DataAPI.database_url
    self.abstract_class = true
    self.primary_key = :id
    self.inheritance_column = nil

    cattr_accessor :updated_at

    # validates :uid, presence: true
    # validates :uid, uniqueness: true
  end

  def columns
    schema.map { |k, v| k.to_sym }
  end

  def get_database_url
    database_url || DataAPI.database_url
  end

  def schema_from_array(columns)
    self.schema = {}
    columns.each do |column|
      column.stringify_keys!
      next if !column.is_a?(Hash) || column['name'].blank?
      self.schema[column['name']] = column
      self.schema[column['name']].except!('name')
    end
  end

  def data_model
    return Models.const_get(name.classify) if Models.const_defined?(name.classify)
    Models.const_set(name.classify, Class.new(DataAPI::Model))
    m = Models.const_get(name.classify)
    begin
      m.establish_connection get_database_url
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error e
    end
    m.cattr_accessor(:organization_code)
    m.organization_code = organization_code
    m.table_name = name
    m.updated_at = updated_at

    if owned_by_user
      case owner_primary_key
      when 'id'
        m.belongs_to :owner, class_name: User, primary_key: :id, foreign_key: owner_foreign_key
      when 'uuid'
        m.belongs_to :owner, class_name: User, primary_key: :uuid, foreign_key: owner_foreign_key
      when 'email'
        m.belongs_to :owner, class_name: User, primary_key: :email, foreign_key: owner_foreign_key
      when 'uid'
        m.belongs_to :owner_identity, ->(o) { where(organization_code: o.class.organization_code) },
                     class_name: UserIdentity, primary_key: :uid, foreign_key: owner_foreign_key
        m.has_one :owner, class_name: :User, through: :owner_identity, source: :user
      end
    end

    m
  end

  def data_api_data
    data_model.all
  end

  def reset_data_model_const
    Models.send(:remove_const, name.classify) if Models.const_defined?(name.classify)
    begin
      data_model.establish_connection get_database_url
      data_model.connection.schema_cache.clear!
      data_model.reset_column_information
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error e
    end
  end

  def reset_data_model_if_needed
    reset_data_model_const if data_model.updated_at != updated_at
  end

  def inspect_data_model
    data_model.inspect
  end

  def remove_blank_columns
    self.schema ||= {}
    schema.delete_if { |k, v| v.blank? }
  end

  def generate_uuid_for_new_columns
    schema.each do |k, v|
      v['uuid'] = SecureRandom.uuid if v['uuid'].blank? || v['uuid'].length < 30
    end
  end

  def set_type_for_new_columns
    schema.each do |k, v|
      v['type'] = :string if v['type'].blank?
    end
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

    old_columns = Hash[previous_version.schema.map { |k, v| v['name'] = k; [v['uuid'], v] }]
    current_columns = Hash[schema.map { |k, v| v['name'] = k; [v['uuid'], v] }]

    deleted_columns = {}

    old_columns.each do |k, v|
      deleted_columns[k] = v unless current_columns.key?(k)
    end

    deleted_columns.each do |uuid, column|
      migration.remove_column name, column['name']
    end

    new_columns = {}

    current_columns.each do |k, v|
      new_columns[k] = v unless old_columns.key?(k)
    end

    new_columns.each do |uuid, column|
      migration.add_column name, column['name'], column['type']
    end

    renamed_columns = {}

    current_columns.each do |k, v|
      renamed_columns[k] = v if old_columns[k].present? && v['name'] != old_columns[k][:name]
    end

    renamed_columns.each do |uuid, column|
      migration.rename_column name, old_columns[uuid]['name'], current_columns[uuid]['name']
    end

    reset_data_model_const
  end

  def drop_db_table
    migration = new_migration
    migration.drop_table name
  end

  def stringify_schema_keys
    self.schema ||= {}
    schema.stringify_keys!
    schema.each_pair do |_, v|
      v ||= {}
      v.stringify_keys!
    end
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
          DataAPI::Model.establish_connection @db_url
        rescue ActiveRecord::AdapterNotSpecified
        end
        DataAPI::Model.connection
      end
    end
    migration
  end

  def check_organization_code
    self.organization_code = nil if organization_code.blank?
  end
end
