class DataAPI::Schema < ActiveSupport::HashWithIndifferentAccess
  COLUMN_ATTRS = {
    'uuid' => String,
    'type' => String,
    'index' => Boolean
  }
  COLUMN_TYPES = %w(string integer float boolean text datetime)
  RESERVED_COLUMN_NAMES = ActiveRecord::Base.instance_methods.map(&:to_s)

  def initialize(constructor = {}, skip_check = false)
    fail unless constructor.is_a?(String)
    super(JSON.parse(constructor))
  rescue
    super(constructor)
  ensure
    return if skip_check
    clear_invalid_columns
    generate_uuid_for_new_columns
    set_default_type_for_columns
    sort_column_attrs
  end

  def load_from_array(columns)
    clear

    columns.each do |column|
      column.stringify_keys!
      next if !column.is_a?(Hash) || column['name'].blank?
      self[column['name']] = column.clone
      self[column['name']][:index] = true if self[column['name']][:index] == 'true'
    end

    validate!
  end

  def validate!
    clear_invalid_columns
    generate_uuid_for_new_columns
    set_default_type_for_columns
    clear_duplicated_uuid_columns
    sort_column_attrs
  end

  def to_s
    to_json
  end

  def to_hash_indexed_with_uuid
    HashWithIndifferentAccess.new(
      Hash[
        map do |column_name, column_attrs|
          [column_attrs[:uuid], column_attrs.merge('name' => column_name)]
        end
      ]
    )
  end

  private

  def clear_invalid_columns
    self.each_pair do |column_name, column_attrs|

      if RESERVED_COLUMN_NAMES.include?(column_name) ||
         column_attrs.blank? ||
         !column_attrs.is_a?(Hash)
        self.delete(column_name)
        next
      end

      column_attrs.each_pair do |attr_name, attr_value|

        column_attrs.delete(attr_name) if \
          !COLUMN_ATTRS.has_key?(attr_name) ||
          !attr_value.is_a?(COLUMN_ATTRS[attr_name])
      end
    end
  end

  def generate_uuid_for_new_columns
    self.each_pair do |_column_name, column_attrs|
      column_attrs[:uuid] = SecureRandom.uuid if \
        column_attrs[:uuid].blank? ||
        column_attrs[:uuid].length < 30
    end
  end

  def set_default_type_for_columns
    self.each_pair do |_column_name, column_attrs|
      column_attrs[:type] = 'string' unless \
        COLUMN_TYPES.include?(column_attrs[:type])
    end
  end

  def sort_column_attrs
    def position_of(key)
      COLUMN_ATTRS.keys.index(key) || key.ord
    end

    self.each_pair do |column_name, column_attrs|
      self[column_name] = column_attrs.sort { |a, b| position_of(a[0]) <=> position_of(b[0]) }.to_h
    end
  end

  def clear_duplicated_uuid_columns
    used_uuids = []
    self.reverse_each do |column_name, column_attrs|
      self.delete(column_name) if used_uuids.include?(column_attrs[:uuid])

      used_uuids << column_attrs[:uuid]
    end
  end
end
