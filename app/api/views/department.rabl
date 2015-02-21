object @department

set_fieldset :department, default_fields: [:code, :name],
                          permitted_fields: [:code, :name, :short_name, :group, :departments]
set_inclusion :department

set_inclusion_field :department, :departments, :department_codes

attributes(*fieldset[:department])

extends('extensions/includable_childs', locals: { self_resource: :department })

node :type do
  :Department
end
