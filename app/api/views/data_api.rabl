object @resource

set_fieldset @resource_name, default_fields: @resource_columns,
                             permitted_fields: @resource_columns
set_inclusion @resource_name

@includable_fields.each do |field|
  case field
  when :owner
    set_inclusion_field @resource_name, :owner, :owner_code, class_name: :User
  end
end

node :id do |data|
  data[@resource_primary_key]
end

attributes(*fieldset[@resource_name])

extends('extensions/includable_childs', locals: { self_resource: @resource_name })

node :_type do
  @resource_name
end

extends('extensions/meta_data', locals: { self_resource: @resource_name })
