class UserIdentity < ActiveRecord::Base

  # Concerns macros
  # Constants
  IDENTITES = {
    guest: 0,
    student: 1,
    staff: 2,
    lecturer: 3,
    professor: 4
  }
  # scope macros

  # association macros
  # Attributes related macros

  # validation macros
  # callbacks

  # other
end
