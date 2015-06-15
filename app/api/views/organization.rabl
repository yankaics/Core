object @organization

set_fieldset :organization, default_fields: [:code, :name, :short_name],
                            permitted_fields: [:code, :name, :short_name, :departments]

set_inclusion :organization, default_includes: [:departments]

set_inclusion_field :organization, :departments, :department_codes

node :id do |org|
  org.code
end

attributes(*(fieldset(:organization) - inclusion_field(:organization).keys))

extends('extensions/includable_childs', locals: { self_resource: :organization })

node :_type do
  :organization
end

extends('extensions/meta_data', locals: { self_resource: :organization })
