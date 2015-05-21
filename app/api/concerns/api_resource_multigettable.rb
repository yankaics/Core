# = Helper To Make Resource APIs Multigettable
#
# A normal resource API can let clients retrieve one specified data at a time:
#
#   GET /posts/3
#
# If it's declared to be multigettable, then clients can retrieve multiple
# specified data like this:
#
#   GET /posts/3,4,8,9
#
# == Usage
#
# Include this +Concern+ in your Grape API class:
#
#   class SampleAPI < Grape::API
#     include APIResourceMultigettable
#   end
#
# then use the +multiget+ method like this:
#
#   resources :posts do
#     # ...
#     get :id do
#       @post = multiget(Post, find_by: :id, max: 12)
#       # ...
#     end
#   end
#
# <em>The +multiget+ method returns a array of or a single model, based
# directly from the requested URL. Further usage of this method can be
# found in the {docs of the
# +HelperMethods+ class}[rdoc-ref:APIResourceMultigettable::HelperMethods].
# </em>
#
# There is also another helper method to determine whether the request is
# multigeting or not:
#
#   multiget?(find_by: id) #=> true of false
#
# It can be used to interact with other condition and functionalities,
# like this:
#
#   inclusion_for :post, root: true,
#     default_includes: (multiget?(find_by: :id) ? [] : [:author])
module APIResourceMultigettable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    # Get multiple resources from a resource URL by specifing ids split by ','
    #
    # Params:
    #
    # +scoped_resource+::
    #   +ActiveRecord::Base+ scoped resources to find data from
    #
    # +find_by+::
    #   +Symbol+ the attribute that is used to find data
    #
    # +max+::
    #   +Integer+ maxium count of returning results
    def multiget(scoped_resource, find_by: :id, max: 10)
      ids = params[find_by].split(',')
      ids = ids[0..(max - 1)]

      if ids.count > 1
        scoped_resource.where(find_by => ids)
      else
        scoped_resource.find_by(find_by => ids[0])
      end
    end

    # Is the a multiget request?
    def multiget?(find_by: :id)
      params[find_by].include?(',')
    end
  end
end
