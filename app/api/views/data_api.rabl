object @resource

set_fieldset @resource_name, default_fields: @resource_columns,
                             permitted_fields: @resource_columns
# set_inclusion @resource_name, default_includes:

node :id do |data|
  data[@resource_primary_key]
end

attributes(*fieldset[@resource_name])

node :type do
  @resource_name.to_s.classify
end
