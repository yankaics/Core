module APIResourceFieldsettable
  extend ActiveSupport::Concern

  included do
    helpers HelperMethods
  end

  module HelperMethods
    def fieldset_for(resource, permitted_fields = [], default_all_permitted_fields = false)
      # put the fields in place
      @fields = (params[:fields].is_a? Hash) ? params[:fields] : Hashie::Mash.new(resource => params[:fields])
      @fields[resource] ||= ''
      # loop over the hash and splits string into array
      @fields.each do |key, val|
        @fields[key] = @fields[key] ? @fields[key].split(',').map(&:to_sym) : []
      end
      # put the permitted_fields in place
      permitted_fields = (permitted_fields.is_a? Hash) ? Hashie::Mash.new(permitted_fields) : Hashie::Mash.new(resource => permitted_fields)
      # filter out unpermitted fields by intersecting
      @fields.each do |key, val|
        @fields[key] &= permitted_fields[key] if permitted_fields[key]
        @fields[key] = permitted_fields[key] if default_all_permitted_fields && @fields[key].blank? && permitted_fields[key]
      end
    end
  end
end
