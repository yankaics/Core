unless @inclusion_field[locals[:self_resource]].blank?
  @inclusion_field[locals[:self_resource]].each do |i_field|
    # include child
    if inclusion[locals[:self_resource]].include?(i_field[:field])
      child i_field[:field], root: i_field[:field], object_root: false do
        template = (i_field[:class_name] || i_field[:field]).to_s.underscore.singularize
        extends template
      end

    # not to include child
    else
      node i_field[:field] do |obj|
        if obj.try(i_field[:id_field]).present?
          obj.try(i_field[:id_field])
        else
          fk = obj.class.try("#{i_field[:field]}_foreign_key")
          obj.try(fk) if fk.present?
        end
      end
      type = (i_field[:class_name] || i_field[:field]).to_s.singularize
      @meta ||= {}
      @meta[locals[:self_resource]] ||= {}
      @meta[locals[:self_resource]][:relations] ||= {}
      @meta[locals[:self_resource]][:relations][i_field[:field]] ||= {}
      @meta[locals[:self_resource]][:relations][i_field[:field]][:type] = type
      @meta[locals[:self_resource]][:relations][i_field[:field]][:url] = request.url.gsub(@request_path, "/#{i_field[:url]}") if i_field[:url].present? && @request_path.is_a?(String)
    end
  end
end
