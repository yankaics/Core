class API::V1 < API
  include APIGuard
  version 'v1'

  mount Me
end
