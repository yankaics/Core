module APIViewHelper
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    def set_fields(resource, default_fields = [], permitted_fields = [])
      @fields ||= {}
      @fields[resource] ||= default_fields
      @fields[resource] &= permitted_fields unless permitted_fields.blank?
    end

    def set_include(resource, default_include = [])
      @include ||= {}
      @include[resource] ||= default_include
    end

    def fields
      @fields ||= {}
    end

    def include
      @include ||= {}
    end
  end
end
