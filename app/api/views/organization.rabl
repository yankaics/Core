set_fieldset :organization, default_fields: [:code, :name],
                            permitted_fields: [:code, :name]
set_include(:organization)

object @organization
attributes(*fieldset[:organization])

node :type do
  :Organization
end
