this = locals[:self_resource]

unless inclusion_field(this).blank?
  inclusion_field(this).each_pair do |field_name, includable_field|
    next if fieldset(this).present? && !fieldset(this).include?(field_name)

    # include child
    if inclusion[this].include?(field_name)

      child field_name.to_sym, root: field_name.to_sym, object_root: false do
        template = (includable_field[:resource_name] || field_name).to_s.underscore.singularize
        extends template
      end

    # not to include child
    else

      node field_name do |obj|
        if obj.try(includable_field[:id_field]).present?
          obj.try(includable_field[:id_field])
        else
          foreign_key = obj.class.try("#{field_name}_foreign_key")
          obj.try(foreign_key) if foreign_key.present?
        end
      end

      # prepare the meta data
      type = (includable_field[:resource_name] || field_name).to_s.underscore.singularize

      meta[this] ||= {}
      meta[this][:relations] ||= {}
      meta[this][:relations][field_name] ||= {}
      meta[this][:relations][field_name][:type] = type
      meta[this][:relations][field_name][:url] = request.url.gsub(@request_path, "/#{includable_field[:url]}") if includable_field[:url].present? && @request_path.is_a?(String)
    end
  end
end
