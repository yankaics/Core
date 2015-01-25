set_fields(:organization, [:code, :name])
set_include(:organization)

object @organization
attributes(*fields[:organization])
