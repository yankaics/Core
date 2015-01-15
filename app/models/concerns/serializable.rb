module Serializable
  extend ActiveSupport::Concern

  module ClassMethods
    def serialize_it(with: nil, options: {})
      scope = current_scope || default_scope {}
      serializer = with || scope.active_model_serializer
      serializer.new(scope, options)
    end

    def serialized_object(options: {})
      serialize_it(options).as_json
    end
  end

  def serialize_it(with: nil, options: {})
    serializer = with || active_model_serializer
    serializer.new(self, options)
  end

  def serialized_object(options: {})
    serialize_it(options).as_json
  end
end
