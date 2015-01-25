module APIResourceIncludable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    def include_for(resource)
      @include ||= {}
      @include[resource] = params[:include] ? params[:include].split(',').map(&:to_sym) : []
    end
  end
end
