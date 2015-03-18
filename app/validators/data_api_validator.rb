class DataAPIValidator < ActiveModel::Validator
  def validate(record)
    reserved_column_names = %w(id)
    used_column_uuids = []

    record.schema.each do |name, column|
      record.errors[:base] << "The schema column name '#{name}' is reserved!" if reserved_column_names.include?(name)
      record.errors[:base] << "The schema column '#{name}' has duplicated uuid!" if used_column_uuids.include?(column[:uuid])
      record.errors[:base] << "The schema column '#{name}' has invalid type!" unless DataAPI::COLUMN_TYPES.include?(column[:type])
      used_column_uuids << column[:uuid]
    end

    if record.id.present? && old_record = DataAPI.find_by(id: record.id)
      old_columns = Hash[old_record.schema.map { |k, v| v[:name] = k; [v[:uuid], v] }]
      current_columns = Hash[record.schema.map { |k, v| v[:name] = k; [v[:uuid], v] }]

      current_columns.each do |uuid, column|
        record.errors[:base] << "The type of a existing column should not be changed!" if old_columns[uuid].present? && old_columns[uuid][:type] != column[:type]
      end
    end
  end
end
