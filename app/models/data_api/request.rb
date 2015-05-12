# = DataAPI request value object
#
# Initialized by the requested path, method and access token, then we can get
# data of the request (e.g.: the scoped resource) form this object.
#
# Caution: this will not verify requests, but only parses it and return
# the corresponding information. Verification, such as checking the validity
# of the access token, should be done in the controller.
class DataAPI::Request
  MAX_MULTIGETTABLE_ITEMS = 100

  attr_reader :full_path, :path, :resource_path,
              :request_method, :access_token,
              :scoped_under_user, :scoped_user
  alias_method :scoped_under_user?, :scoped_under_user

  def initialize(path, access_token: nil)
    @full_path = path
    @path = path
    # remove format extension in path
    @path.slice!(%r{\..+$})
    # remove versioning in path
    @path.slice!(%r{^v[0-9]{1,2}\/})

    # Is the requested resource scoped under a user?
    if @path.match(%r{^me\/})
      @scoped_under_user = true
      @resource_path = @path.gsub(%r{^me\/}, '')
    else
      @scoped_under_user = false
      @resource_path = @path
    end

    access_token = Doorkeeper::AccessToken.by_token(access_token) if access_token.is_a?(String)
    @access_token = access_token
  end

  # Returns the corresponding DataAPI
  def data_api
    return @data_api if @data_api
    @data_api = DataAPI.find_by_path(resource_path, include_not_public: scoped_under_user?)
  end

  # Does the corresponding DataAPI presents?
  def present?
    !!data_api
  end

  # Returns the user that this request is scoped under of
  def scoped_user
    return nil unless scoped_under_user?
    return nil unless access_token.respond_to?(:resource_owner)
    access_token.resource_owner
  end

  # Returns the scoped requested resource collection
  def resource_collection
    return @resource_collection if @resource_collection

    @resource_collection = data_api.data_model.all

    # scope the collection to the current user if needed
    if scoped_under_user? && scoped_user.present?
      case data_api.owner_primary_key
      when 'uid'
        @resource_collection = @resource_collection.none if \
          scoped_user.organization_code != data_api.organization_code
        @resource_collection = @resource_collection.where(
          data_api.owner_foreign_key => scoped_user.try(data_api.owner_primary_key)
        )
      else
        @resource_collection = @resource_collection.where(
          data_api.owner_foreign_key => scoped_user.try(data_api.owner_primary_key)
        )
      end
    elsif scoped_under_user? && scoped_user.blank?
      @resource_collection = @resource_collection.none
    end

    @resource_collection
  end

  # Is this request for specified resource?
  # e.g.: '/resources/20' or '/resources/1,5,7'
  def resource_specified?
    !!data_api.specified_resource_ids
  end

  # Returns the single requested resource
  def specified_resource
    return @requested_resource if @requested_resource_processed
    @requested_resource_processed = true

    if data_api.specified_resource_ids.present?
      # multigettable, a request path can be like this: '/resources/1,5,7'
      ids = data_api.specified_resource_ids.split(',')
      ids = ids[0..(MAX_MULTIGETTABLE_ITEMS - 1)]

      if ids.count > 1
        @requested_resource = resource_collection.where(data_api.primary_key => ids)
      else
        @requested_resource = resource_collection.find_by(data_api.primary_key => ids[0])
      end

      if @requested_resource.blank? && data_api.primary_key != 'id'
        if ids.count > 1
          @requested_resource = resource_collection.where(id: ids)
        else
          @requested_resource = resource_collection.find_by(id: ids[0])
        end
      end

      @requested_resource
    end
  end

  alias_method :specified_resources, :specified_resource
end
