class DataAPI::DatabaseMaintainer
  attr_accessor :model, :migration

  def initialize(model)
    self.model = model
    self.migration = new_migration(model)
  end

  def create_table(table_name, schema)
    migration.transaction do
      migration.create_table table_name do |t|
        schema.each do |column_name, column_attrs|
          t.send(column_attrs[:type], column_name)
        end
      end

      schema.each do |column_name, column_attrs|
        migration.add_index table_name, column_name if column_attrs[:index]
      end
    end
  end

  def drop_table(table_name)
    migration.transaction do
      migration.drop_table table_name
    end
  end

  def update_table(old_table_name, new_table_name, old_schema, new_schema, test_run: false)
    changes = []

    migration.transaction do

      # Rename the table if needed

      if new_table_name != old_table_name
        migration.rename_table old_table_name, new_table_name unless test_run
        changes << ['rename_table', [old_table_name, new_table_name]]
      end

      table_name = new_table_name

      # Get column data

      new_column_data = new_schema.to_hash_indexed_with_uuid
      old_column_data = old_schema.to_hash_indexed_with_uuid

      # Deal with deleted columns

      deleted_columns = {}

      old_column_data.each do |uuid, column_attrs|
        deleted_columns[uuid] = column_attrs unless new_column_data.key?(uuid)
      end

      deleted_columns.each do |_uuid, column_attrs|
        migration.remove_column table_name, column_attrs[:name] unless test_run
        changes << ['remove_column', [table_name, column_attrs[:name]]]
      end

      # Create new columns

      new_columns = {}

      new_column_data.each do |uuid, column_attrs|
        new_columns[uuid] = column_attrs unless old_column_data.key?(uuid)
      end

      new_columns.each do |_uuid, column_attrs|
        migration.add_column table_name, column_attrs[:name], column_attrs[:type] unless test_run
        changes << ['add_column', [table_name, column_attrs[:name], column_attrs[:type]]]
      end

      # Deal with renamed columns

      renamed_columns = {}

      new_column_data.each do |uuid, column_attrs|
        renamed_columns[uuid] = column_attrs if old_column_data[uuid].present? &&
                                                column_attrs[:name] != old_column_data[uuid][:name]
      end

      renamed_columns.each do |uuid, _column_attrs|
        migration.rename_column table_name, old_column_data[uuid][:name], new_column_data[uuid][:name] unless test_run
        changes << ['rename_column', [table_name, old_column_data[uuid][:name], new_column_data[uuid][:name]]]
      end

      # Deal with added indexes

      added_indexes = {}

      new_column_data.each do |uuid, column_attrs|
        added_indexes[uuid] = column_attrs if old_column_data[uuid].present? &&
                                              column_attrs[:index] &&
                                              !old_column_data[uuid][:index]
      end

      added_indexes.each do |_uuid, column_attrs|
        migration.add_index table_name, column_attrs[:name] unless test_run
        changes << ['add_index', [table_name, column_attrs[:name]]]
      end

      # Deal with removed indexes

      removed_indexes = {}

      new_column_data.each do |uuid, column_attrs|
        removed_indexes[uuid] = column_attrs if old_column_data[uuid].present? &&
                                                !column_attrs[:index] &&
                                                old_column_data[uuid][:index]
      end

      removed_indexes.each do |_uuid, column_attrs|
        migration.remove_index table_name, column_attrs[:name] unless test_run
        changes << ['remove_index', [table_name, column_attrs[:name]]]
      end

      # Deal with type changed columns

      # type_changed_columns = {}

      # new_column_data.each do |uuid, column_attrs|
      #   type_changed_columns[uuid] = column_attrs if old_column_data[uuid].present? &&
      #                                                column_attrs[:type] != old_column_data[uuid][:type]
      # end

      # type_changed_columns.each do |uuid, _column_attrs|
      #   migration.change_column table_name, new_column_data[uuid][:name], new_column_data[uuid][:type]
      # end

    end

    changes
  end

  private

  def new_migration(target_model = model)
    migration = ActiveRecord::Migration.new

    migration.instance_exec(target_model) do |model|
      @model = model

      def connection
        @model.connection
      end
    end

    migration
  end
end
