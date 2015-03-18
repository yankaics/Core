module APIResourceMultigettable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    ##
    # Get multiple resources from a resource URL by specifing ids split by ','
    #
    # Params:
    #
    # +scoped_resource+::
    #   +ActiveRecord::Base+ scoped resources to find data from
    #
    # +find_by+::
    #   +ActiveRecord::Base+ the attribute that is used to find data
    #
    # +max+::
    #   +ActiveRecord::Base+ maxium count of returning results
    #
    def multiget(scoped_resource, find_by: :id, max: 10)
      ids = params[find_by].split(',')
      ids = ids[0..(max - 1)]

      if ids.count > 1
        scoped_resource.where(find_by => ids)
      else
        scoped_resource.find_by(find_by => ids[0])
      end
    end

    def multiget?(find_by: :id)
      params[find_by].include?(',')
    end
  end
end
