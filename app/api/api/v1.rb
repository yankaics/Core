class API::V1 < API
  include APIResourceFieldsettable
  include APIResourceIncludable
  include APIResourceSortable
  include APIResourceMultigettable
  version 'v1'

  mount Me
  mount Organizations
  mount Utilities
end
