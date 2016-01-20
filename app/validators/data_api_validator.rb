class DataAPIValidator < ActiveModel::Validator
  def validate(record)
    if record.id.present? && old_record = DataAPI.find_by(id: record.id)
      old_columns = Hash[old_record.schema.map { |_k, v| [v['uuid'], v] }]
      current_columns = Hash[record.schema.map { |_k, v| [v['uuid'], v] }]

      current_columns.each do |uuid, column|
        record.errors[:schema] << "The type of a existing column should not be changed!" if record.maintain_schema && old_columns[uuid].present? && old_columns[uuid]['type'] != column['type']
      end
    end

    if record.owner_foreign_key.present?
      record.errors[:owner_foreign_key] << "The owner_foreign_key column name \"#{record.owner_foreign_key}\" does not exist on the schema!" if (record.owner_foreign_key != 'id') && !record.schema.keys.include?(record.owner_foreign_key)
    end

    record.errors[:maintain_schema] << "This can not be turned off while using system database!" if record.using_system_database? && !record.maintain_schema

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
