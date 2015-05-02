# Some helpers for Grape to construct an sortable resource API easily.
module APIResourceSortable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    ##
    # Gets the `sort` parameter with the format 'resourses?sort=-created_at,name',
    # verify and converts it into an safe Hash that can be passed into the .order
    # method.
    #
    # Params:
    #
    # +default_order+::
    #   +Hash+ the default value to return if the sort parameter is not provided
    #
    def sortable(default_order: {})
      # get the parameter
      sort_by = params[:sort] || params[:sort_by]

      if sort_by.is_a? String
        # split it
        sort_by_attrs = sort_by.gsub(/[^a-zA-Z0-9\-_,]/, '').split(',')

        # save it
        @sort = {}
        sort_by_attrs.each do |attrb|
          if attrb.match(/^-/)
            @sort[attrb.gsub(/^-/, '')] = :desc
          else
            @sort[attrb] = :asc
          end
        end
      else
        @sort = default_order
      end
    end

    ##
    # Helper to get the sort data
    #
    def sort
      @sort
    end
  end
end
