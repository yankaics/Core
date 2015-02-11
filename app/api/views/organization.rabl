set_fieldset :organization, default_fields: [:code, :name, :short_name],
                            permitted_fields: [:code, :name, :short_name]
set_inclusion :organization

object @organization
attributes(*fieldset[:organization])

node :type do
  :Organization
end
