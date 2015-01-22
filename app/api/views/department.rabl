set_fields(:department, [:code, :name])
set_include(:department)

object @department
attributes(*@fields[:department])
