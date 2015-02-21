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
      node i_field[:id] do |obj|
        obj.send(i_field[:id])
      end
      node i_field[:field] do
        type = (i_field[:class_name] || i_field[:field]).to_s.singularize.camelize
        meta = {}
        meta[:key] = i_field[:id]
        meta[:type] = type
        meta[:url] = i_field[:resource_url] unless i_field[:resource_url].blank?
        meta
      end
    end
  end
end
