# A fake ActiveRecord model that can change the reflected model on the fly
class DataAPI::APIData < ActiveRecord::Base
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
