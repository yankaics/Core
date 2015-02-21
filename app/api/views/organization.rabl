object @organization

set_fieldset :organization, default_fields: [:code, :name, :short_name],
                            permitted_fields: [:code, :name, :short_name, :departments]

set_inclusion :organization, default_includes: [:departments]

set_inclusion_field :organization, :departments, :department_codes

attributes(*fieldset[:organization])

extends('extensions/includable_childs', locals: { self_resource: :organization })

node :type do
  :Organization
end
