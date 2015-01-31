module APIResourceIncludable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    ##
    # Gets the include parameters, organize them into a +@inclusion+ hash for model to use
    # inner-join queries and/or templates to render relation attributes included.
    # Following the URL rules of JSON API:
    # http://jsonapi.org/format/#fetching-includes
    #
    # Params:
    #
    # +resource+::
    #   +Symbol+ name of resource to receive the inclusion
    #
    def inclusion_for(resource)
      @inclusion ||= {}
      @inclusion[resource] = params[:include] ? params[:include].split(',').map(&:to_sym) : []
    end
  end
end
