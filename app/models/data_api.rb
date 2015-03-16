class DataAPI < ActiveRecord::Base
  has_paper_trail class_name: 'DataAPIVersion'

  COLUMN_TYPES = %w(string integer float boolean text datetime)

  scope :global, -> { where(organization_code: nil) }
  scope :local, -> { where.not(organization_code: nil) }

  belongs_to :organization, primary_key: :code, foreign_key: :organization_code

  serialize :schema, HashWithIndifferentAccess

  validates_with DataAPIValidator
  validates :name, :path, presence: true
  validates :name, format: { with: /\A[a-z0-9_]+\z/ }
  validates :path, format: { with: /\A[a-z0-9_]+(\/[a-z0-9_]+)?(\/[a-z0-9_]+)?\z/ }

  after_find :reset_data_model_if_needed, :inspect_data_model
  before_validation :convert_schema_hash_to_hash_with_indifferent_access, :remove_blank_columns, :generate_uuid_for_new_columns, :set_type_for_new_columns
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

  module Models
  end

  class Model < ActiveRecord::Base
    establish_connection DataAPI.database_url
    self.abstract_class = true
    self.primary_key = :id

    cattr_accessor :updated_at

    validates :uid, presence: true
    validates :uid, uniqueness: true
  end

  def schema_from_array(columns)
    self.schema = HashWithIndifferentAccess.new
    columns.each do |column|
      next if !column.is_a?(Hash) || column[:name].blank?
      self.schema[column[:name]] = column
      self.schema[column[:name]].except!(:name)
    end
  end

  def data_model
    return Models.const_get(name.classify) if Models.const_defined?(name.classify)
    Models.const_set(name.classify, Class.new(DataAPI::Model))
    m = Models.const_get(name.classify)
    m.table_name = name
    m.updated_at = updated_at
    m
  end

  def reset_data_model_const
    Models.send(:remove_const, name.classify) if Models.const_defined?(name.classify)
    data_model.connection.schema_cache.clear!
    data_model.reset_column_information
  end

  def reset_data_model_if_needed
    reset_data_model_const if data_model.updated_at != updated_at
  end

  def inspect_data_model
    data_model.inspect
  end

  def remove_blank_columns
    self.schema ||= HashWithIndifferentAccess.new
    schema.delete_if { |k, v| v.blank? }
  end

  def generate_uuid_for_new_columns
    schema.each do |k, v|
      v[:uuid] = SecureRandom.uuid if v[:uuid].blank? || v[:uuid].length < 30
    end
  end

  def set_type_for_new_columns
    schema.each do |k, v|
      v[:type] = :string if v[:type].blank?
    end
  end

  def create_db_table
    migration = new_migration

    migration.create_table name do |t|
      t.string :uid, null: false

      schema.each do |k, v|
        t.send(v[:type], k)
      end

      t.timestamps
    end

    migration.add_index name, :uid, unique: true
  end

  def change_db_table
    migration = new_migration
    previous_version = DataAPI.find(id)
    old_table_name = previous_version.name
    current_table_name = name

    if current_table_name != old_table_name
      migration.rename_table old_table_name, current_table_name
    end

    old_columns = Hash[previous_version.schema.map { |k, v| v[:name] = k; [v[:uuid], v] }]
    current_columns = Hash[schema.map { |k, v| v[:name] = k; [v[:uuid], v] }]

    deleted_columns = HashWithIndifferentAccess.new

    old_columns.each do |k, v|
      deleted_columns[k] = v unless current_columns.key?(k)
    end

    deleted_columns.each do |uuid, column|
      migration.remove_column name, column[:name]
    end

    new_columns = HashWithIndifferentAccess.new

    current_columns.each do |k, v|
      new_columns[k] = v unless old_columns.key?(k)
    end

    new_columns.each do |uuid, column|
      migration.add_column name, column[:name], column[:type]
    end

    renamed_columns = HashWithIndifferentAccess.new

    current_columns.each do |k, v|
      renamed_columns[k] = v if old_columns[k].present? && v[:name] != old_columns[k][:name]
    end

    renamed_columns.each do |uuid, column|
      migration.rename_column name, old_columns[uuid][:name], current_columns[uuid][:name]
    end

    reset_data_model_const
  end

  def drop_db_table
    migration = new_migration
    migration.drop_table name
  end

  private

  def new_migration
    migration = ActiveRecord::Migration.new
    migration.instance_eval do
      def connection
        DataAPI::Model.connection
      end
    end
    migration
  end

  def convert_schema_hash_to_hash_with_indifferent_access
    return if schema.is_a? HashWithIndifferentAccess
    self.schema = HashWithIndifferentAccess.new(schema)
  end
end
