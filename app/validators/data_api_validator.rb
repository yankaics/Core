class DataAPIValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:base] << "The name should start with an alphabet!" unless record.name.present? && record.name[0].match(/[a-z]/)
    record.errors[:base] << "The name should only contains a-z 0-9 and baselines!" unless record.name.present? && record.name.match(/^[a-z0-9_]+$/)
    record.errors[:base] << "The path is not valid!" unless record.path.present? && record.path.match(/^[a-z0-9_]+(\/[a-z0-9_]+)?(\/[a-z0-9_]+)?$/)

    reserved_column_names = [:uid, :created_at, :updated_at]
    used_uuid = []

    record.schema.each do |name, column|
      record.errors[:base] << "The schema column name '#{name}' is reserved!" if reserved_column_names.include?(name)
      record.errors[:base] << "The schema column '#{name}' has duplicated uuid!" if used_uuid.include?(column[:uuid])
      used_uuid << column[:uuid]
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
