class API::V1 < API
  include APIGuard
  include APIViewHelper
  include APIResourceFieldsettable
  include APIResourceIncludable
  version 'v1'

  mount Me
end
