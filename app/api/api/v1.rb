class API::V1 < API
  include APIGuard
  include APIResourceFieldsettable
  include APIResourceIncludable
  include APIResourceMultigettable
  version 'v1'

  mount Me
  mount Organizations
end
