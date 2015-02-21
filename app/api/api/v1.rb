class API::V1 < API
  include APIGuard
  include APIResourceFieldsettable
  include APIResourceIncludable
  version 'v1'

  mount Me
  mount Organizations
end
