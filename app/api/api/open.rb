class API::Open < API
  include APIGuard
  include APIResourceFieldsettable
  include APIResourceIncludable
  include APIResourcePaginatable
  include APIResourceSortable

  route :any, '*path' do
    @request_path = params.path
    # remove format extension in path
    @request_path.slice!(/\..+$/)
    # remove versioning in path
    @request_path.slice!(/^v[0-9]{1,2}\//)

    @request_method = request.request_method

    # Find if there is a matching TransferAPI
    if false

    # Find if there is a matching DataAPI
    elsif (
      @data_api_request = DataAPI::Request.new(@request_path, access_token: current_access_token)
    ).present?
      # Guard the API if the requested resource is scoped under a user
      if @data_api_request.scoped_under_user && @request_method != 'GET'
        guard!(scopes: ['api:write'])
      elsif @data_api_request.scoped_under_user
        guard!(scopes: ['api'])
      end

      # prepare variables
      @data_api = @data_api_request.data_api
      @resource_name = @data_api.name.to_sym
      @resource_fields = @data_api.fields
      @includable_fields = @data_api.includable_fields

      # process request
      case @request_method

      # GET requests
      when 'GET'
        # fieldset
        fieldset_for @resource_name, permitted_fields: @resource_fields,
                                     show_all_permitted_fields_by_default: true,
                                     root: true
        # inclusion
        inclusion_for @resource_name, root: true
        # fieldset for inclusion
        if @data_api.owner?
          fieldset_for :user, permitted_fields: User::PUBLIC_ATTRS,
                              show_all_permitted_fields_by_default: true
        end

        # resource specified, e.g.: 'GET /resources/1'
        if @data_api_request.resource_specified?
          @resource = @data_api_request.specified_resource
          if @resource.present?
            render rabl: 'data_api'
            return
          end

        # resource unspecified, e.g.: 'GET /resources'
        else
          @resource_collection = @data_api_request.resource_collection
          # sortable
          sortable default_order: @data_api.default_order
          # pagination
          pagination @resource_collection.size, default_per_page: 20, maxium_per_page: 100

          @resources = @resource_collection.order(sort).page(page).per(per_page)
          render rabl: 'data_apis'
          return
        end

      # POST requests, create resource
      when 'POST'
        # this is only for user scoped resources,
        # the access token permission is verified on the above 'guard' section
        error! 403, 403 unless @data_api.owner_writable
        error! 403, 403 unless @data_api_request.scoped_under_user
        error!({ error: 'blank_data', description: "" }, 400) if params[@data_api.name].blank?
        attrs = params[@data_api.name].slice(*@data_api.write_permitted_fields).to_h
        @resource = @data_api_request.resource_collection.build(attrs)
        if @resource.save
          status 201
          render rabl: 'data_api'
          return
        else
          error! 400, 400
        end

      # PUT requests, create resource
      when 'PUT'
        # this is only for user scoped resources,
        # the access token permission is verified on the above 'guard' section
        error! 403, 403 unless @data_api.owner_writable
        error! 403, 403 unless @data_api_request.scoped_under_user
        error! 404, 404 if @data_api_request.specified_resource.blank? ||
                           @data_api_request.specified_resource.is_a?(Array)
        error!({ error: 'blank_data', description: "" }, 400) if params[@data_api.name].blank?
        attrs = params[@data_api.name].slice(*@data_api.write_permitted_fields).to_h
        @resource = @data_api_request.specified_resource
        @resource.assign_attributes(attrs)
        if @resource.save
          status 200
          render rabl: 'data_api'
          return
        else
          error! 400, 400
        end

      # DELETE requests, deletes resource
      when 'DELETE'
        # this is only for user scoped resources,
        # the access token permission is verified on the above 'guard' section
        error! 403, 403 unless @data_api.owner_writable
        error! 403, 403 unless @data_api_request.scoped_under_user
        error! 404, 404 if @data_api_request.specified_resource.blank? ||
                           @data_api_request.specified_resource.is_a?(Array)
        @resource = @data_api_request.specified_resource
        if @resource.destroy
          status 200
          render rabl: 'data_api'
          return
        else
          error! 400, 400
        end
      end
    end

    error! 404, 404
  end
end
