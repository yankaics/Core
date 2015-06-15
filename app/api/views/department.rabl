object @department

set_fieldset :department, default_fields: [:code, :name],
                          permitted_fields: [:code, :name, :short_name, :group, :departments]
set_inclusion :department

set_inclusion_field :department, :departments, :department_codes

node :id do |dep|
  dep.code
end

attributes(*(fieldset(:department) - inclusion_field(:department).keys))

extends('extensions/includable_childs', locals: { self_resource: :department })

node :_type do
  :department
end

extends('extensions/meta_data', locals: { self_resource: :department })
