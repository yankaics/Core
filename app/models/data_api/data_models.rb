# A constructor and container of DataAPI::DataModel classes
# that needs to be created on the fly
module DataAPI::DataModels
  # Get a DataModel class with its name
  def self.get(name)
    const_get(name)
  end

  # Put a class into the container
  def self.set(name, klass)
    const_set(name, klass)
  end

  # Construct a new DataModel class
  def self.construct(name, options = {})
    set(name, Class.new(DataAPI::DataModel))
    model = get(name)

    model.database_url = options[:database_url] || DataAPI.database_url
    model.table_name = options[:table_name] || name.underscore
    model.organization_code = options[:organization_code]
    model.updated_at = options[:updated_at]
    model.owned_by_user = options[:owned_by_user]
    model.owner_primary_key = options[:owner_primary_key]
    model.owner_foreign_key = options[:owner_foreign_key]

    model.max_paginates_per 10_000

    model.validates options[:primary_key], uniqueness: true

    model.set_owner_relation
    model.test_db_connection

    model
  end

  # Determine if a DataModel class exists by its name
  def self.has?(name)
    Object.const_defined? "DataAPI::DataModels::#{name}"
  end

  # Remove a DataModel class by its name
  def self.remove(name)
    remove_const(name)
  end

  # Remove a DataModel class by its name if exists
  def self.remove_if_exists(name)
    remove_const(name) if has?(name)
  end
end
