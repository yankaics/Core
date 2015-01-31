set_fieldset :department, default_fields: [:code, :name],
                          permitted_fields: [:code, :name]
set_inclusion :department

object @department
attributes(*fieldset[:department])

node :type do
  :Department
end
