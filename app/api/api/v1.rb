class API::V1 < API
  helpers APIMetaDataHelper
  helpers APIHelper::Fieldsettable
  helpers APIHelper::Includable
  helpers APIHelper::Paginatable
  helpers APIHelper::Sortable
  helpers APIHelper::Filterable
  helpers APIHelper::Multigettable
  helpers APIHelper::Sortable

  version 'v1'

  mount Me
  mount Users
  mount Organizations
  mount Utilities
  mount SMS
end
