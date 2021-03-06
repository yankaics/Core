module EnumHumanizable
  extend ActiveSupport::Concern

  module ClassMethods

    def human_enum_value(attribute, value, options = {})
      options   = { count: 1 }.merge!(options)
      parts     = attribute.to_s.split(".")
      attribute = parts.pop.pluralize
      namespace = parts.join("/") unless parts.empty?
      attributes_scope = "#{self.i18n_scope}.attributes"

      if namespace
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}/#{namespace}.#{attribute}.#{value}"
        end
        defaults << :"#{attributes_scope}.#{namespace}.#{attribute}.#{value}"
      else
        defaults = lookup_ancestors.map do |klass|
          :"#{attributes_scope}.#{klass.model_name.i18n_key}.#{attribute}.#{value}"
        end
      end

      defaults << :"attributes.#{attribute}.#{value}"
      defaults << options.delete(:default) if options[:default]
      defaults << value.to_s.humanize

      options[:default] = defaults
      I18n.translate(defaults.shift, options)
    end

    def enum_for_select(attribute)
      selections = const_get(attribute.to_s.pluralize.upcase)
      selections.map { |k, v| [human_enum_value(attribute, k), k] }
    end
  end
end
