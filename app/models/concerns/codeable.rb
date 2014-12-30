module Codeable
  extend ActiveSupport::Concern

  included do
    default_scope { order('code ASC') }
    validates :code, format: { with: /\A[a-zA-Z0-9]+\z/ }
    extend FriendlyId
    friendly_id :code
  end

  module ClassMethods

    # ...

  end
end
