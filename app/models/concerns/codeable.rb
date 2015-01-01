module Codeable
  extend ActiveSupport::Concern

  included do
    default_scope { order('code ASC') }
    validates :code, format: { with: /\A[a-zA-Z0-9]+\z/ }
  end

  module ClassMethods

    # ...

  end
end
