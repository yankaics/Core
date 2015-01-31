module APIViewHelper
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    ##
    # Sets the default and permitted fields.
    #
    def set_fieldset(resource, default_fields: [], permitted_fields: [])
      @fieldset ||= {}
      @fieldset[resource] ||= default_fields
      @fieldset[resource] &= permitted_fields
    end

    def set_inclusion(resource, default_inclusion: [])
      @inclusion ||= {}
      @inclusion_field ||= {}
      @inclusion[resource] ||= default_inclusion
    end

    def set_inclusion_field(self_resource, field, id, class_name: nil, default_included: false, resource_url: nil)
      return if !@fieldset.blank? && !@fieldset[self_resource].include?(field)
      @inclusion_field ||= {}
      @inclusion_field[self_resource] ||= []
      field_data = {
        field: field,
        class_name: class_name,
        id: id,
        default_included: default_included,
        resource_url: resource_url
      }
      @inclusion_field[self_resource] << field_data
      @fieldset[self_resource].delete(field)
    end

    def fieldset
      @fieldset ||= {}
    end

    def inclusion
      @inclusion ||= {}
    end
  end
end
