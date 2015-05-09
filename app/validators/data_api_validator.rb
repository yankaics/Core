class DataAPIValidator < ActiveModel::Validator
  def validate(record)
    reserved_column_names = %w(id)
    used_column_uuids = []

    record.stringify_schema_keys

    record.schema.each do |name, column|
      record.errors[:schema] << "The schema column name '#{name}' is reserved!" if reserved_column_names.include?(name)
      record.errors[:schema] << "The schema column '#{name}' has duplicated uuid!" if used_column_uuids.include?(column['uuid'])
      column['type'] = column['type'].to_s
      record.errors[:schema] << "The schema column '#{name}' has invalid type!" unless DataAPI::COLUMN_TYPES.include?(column['type'])
      used_column_uuids << column['uuid']
    end

    if record.id.present? && old_record = DataAPI.find_by(id: record.id)
      old_columns = Hash[old_record.schema.map { |_k, v| [v['uuid'], v] }]
      current_columns = Hash[record.schema.map { |_k, v| [v['uuid'], v] }]

      current_columns.each do |uuid, column|
        record.errors[:schema] << "The type of a existing column should not be changed!" if record.maintain_schema && old_columns[uuid].present? && old_columns[uuid]['type'] != column['type']
      end
    end

    if record.owner_foreign_key.present?
      record.errors[:owner_foreign_key] << "The owner_foreign_key column name \"#{record.owner_foreign_key}\" does not exist on the schema!" if !record.schema.keys.include?(record.owner_foreign_key)
    end

    record.errors[:maintain_schema] << "This can not be turned off while using system database!" if record.database_url.blank? && !record.maintain_schema

    # if record.database_url.present?
    #   begin
    #     record.data_model.establish_connection record.database_url
    #     record.data_model.connection.schema_cache.clear!
    #     record.data_model.reset_column_information
    #     record.data_model.last
    #   rescue ActiveRecord::ActiveRecordError => e
    #     record.errors[:database_url] << "Error connecting database!"
    #   end
    # end
  end
end
