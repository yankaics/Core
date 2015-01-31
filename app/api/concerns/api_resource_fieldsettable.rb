module APIResourceFieldsettable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    ##
    # Gets the fields parameters, organize them into a +@fieldset+ hash for model to select certain
    # fields and/or templates to render specified fieldset. Following the URL rules of JSON API:
    # http://jsonapi.org/format/#fetching-sparse-fieldsets
    #
    # Params:
    #
    # +resource+::
    #   +Symbol+ name of resource to receive the fieldset
    #
    # +root+::
    #   +Boolean+ should this resource take the parameter from +fields+ while no type is specified
    #
    # +permitted_fields+::
    #   +Array+ of +Symbol+s list of accessible fields used to filter out unpermitted fields,
    #   defaults to permit all
    #
    # +default_fields+::
    #   +Array+ of +Symbol+s list of fields to show by default
    #
    # +show_all_permitted_fields_by_default+::
    #   +Boolean+ if set to true, @fieldset will be set to all permitted_fields when the current
    #   resource's fieldset isn't specified
    #
    # Example Result:
    #
    #     fieldset_for :user, root: true
    #     fieldset_for :group
    #
    #     # @fieldset => {
    #     #                :user => [:id, :name, :email, :groups],
    #     #                :group => [:id, :name]
    #     #              }
    #
    def fieldset_for(resource, root: false, permitted_fields: [], show_all_permitted_fields_by_default: false, default_fields: [])
      @fieldset ||= Hashie::Mash.new

      # put the fields in place
      if params[:fields].is_a? Hash
        @fieldset[resource] = params[:fields][resource] || params[:fields][resource.to_s.camelize]
      elsif root
        @fieldset[resource] = params[:fields]
      end

      # splits the string into array of symbles
      @fieldset[resource] = @fieldset[resource] ? @fieldset[resource].split(',').map(&:to_sym) : nil

      # set default fields?
      @fieldset[resource] = default_fields if @fieldset[resource].blank? && !default_fields.blank?

      # filter out unpermitted fields by intersecting them
      @fieldset[resource] &= permitted_fields if !@fieldset[resource].blank? && !permitted_fields.blank?

      # set default fields to permitted_fields?
      @fieldset[resource] = permitted_fields if show_all_permitted_fields_by_default && @fieldset[resource].blank? && !permitted_fields.blank?
    end
  end
end
