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
    def inclusion_for(resource, root: false, default_includes: [])
      @inclusion ||= Hashie::Mash.new
      @meta ||= Hashie::Mash.new

      # put the includes in place
      if params[:include].is_a? Hash
        @inclusion[resource] = params[:include][resource] || params[:include][resource]
      elsif root
        @inclusion[resource] = params[:include]
      end

      # splits the string into array of symbles
      @inclusion[resource] = @inclusion[resource] ? @inclusion[resource].split(',').map(&:to_sym) : default_includes
    end

    ##
    # View Helper to set the inclusion and default_inclusion.
    #
    def set_inclusion(resource, default_includes: [])
      @inclusion ||= {}
      @inclusion_field ||= {}
      @inclusion[resource] = default_includes if !@inclusion[resource].is_a? Array
    end

    ##
    # View Helper to set the inclusion details.
    #
    def set_inclusion_field(self_resource, field, id_field, class_name: nil, url: nil)
      return if (@fieldset.present? && @fieldset[self_resource].present? && !@fieldset[self_resource].include?(field))

      @inclusion_field ||= {}
      @inclusion_field[self_resource] ||= []
      field_data = {
        field: field,
        id_field: id_field,
        class_name: class_name,
        url: url
      }
      @inclusion_field[self_resource] << field_data
      @fieldset[self_resource].delete(field) if @fieldset[self_resource].present?
    end

    ##
    # Getter for the inclusion data.
    #
    def inclusion(resource = nil, field = nil)
      if resource.blank?
        @inclusion ||= {}
      elsif field.blank?
        (@inclusion ||= {})[resource] ||= []
      else
        return false if (try(:fieldset, resource).present? && !fieldset(resource, field))
        inclusion(resource).include?(field)
      end
    end
  end
end
