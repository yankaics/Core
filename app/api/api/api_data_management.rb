class API::APIDataManagement < API
  include APIResourceFieldsettable
  include APIResourceIncludable
  include APIResourceFilterable
  include APIResourcePaginatable
  include APIResourceSortable

  route :any, 'data_management/*path' do
    @request_path = params.path
    # remove format extension in path
    @request_path.slice!(/\..+$/)
    # remove versioning in path
    @request_path.slice!(/^v[0-9]{1,2}\//)

    @request_method = request.request_method

    # Find if there is a matching DataAPI
    if (
      @data_api_request = DataAPI::Request.new(@request_path, access_token: current_access_token, include_inaccessible: true, include_not_public: true)
    ).present?

      # prepare variables
      @data_api = @data_api_request.data_api
      @resource_name = @data_api.name.to_sym
      @resource_fields = @data_api.fields
      @includable_fields = @data_api.includable_fields

      # verify the request
      error!(401, 401) if params[:key] != @data_api.management_api_key

      # process request
      case @request_method

      # GET requests
      when 'GET'
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
          # filterable
          @resource_collection = filter(@resource_collection)
          # sortable
          sortable default_order: @data_api.default_order
          # pagination
          maxium_per_page = current_application.try(:core_app?) ? 5000 : 100
          pagination @resource_collection.size, default_per_page: 20, maxium_per_page: maxium_per_page

          @resources = @resource_collection.order(sort).page(page).per(per_page)
          render rabl: 'data_apis'
          return
        end

      # POST requests, create resource
      when 'POST'
        error!({ error: 'no_data_provided', description: "The #{@data_api.name} parameter is expected to exist and be a object." }, 400) if params[@data_api.name].blank? || !params[@data_api.name].is_a?(Hash)
        attrs = params[@data_api.name].slice(*@data_api.writable_fields).to_h
        @resource = @data_api_request.resource_collection.build(attrs)

        if @resource.save
          status 201
          render rabl: 'data_api'
          return
        else
          error!({ error: 400, description: "#{@resource.errors.full_messages.join(', ')}" }, 400)
        end

      # PATCH requests, update resource
      when 'PATCH'
        error!({ error: 'no_data_provided', description: "The #{@data_api.name} parameter is expected to exist and be a object." }, 400) if params[@data_api.name].blank? || !params[@data_api.name].is_a?(Hash)
        attrs = params[@data_api.name].slice(*@data_api.writable_fields).to_h
        @resource = @data_api_request.specified_resource
        @resource.assign_attributes(attrs)

        if @resource.save
          status 200
          render rabl: 'data_api'
          return
        else
          error!({ error: 400, description: "#{@resource.errors.full_messages.join(', ')}" }, 400)
        end

      # PUT requests, create or replace resource
      when 'PUT'
        error! 400, 400 if @data_api_request.specified_resource_id.blank?

        error!({ error: 'no_data_provided', description: "The #{@data_api.name} parameter is expected to exist and be a object." }, 400) if params[@data_api.name].blank? || !params[@data_api.name].is_a?(Hash)
        permitted_fields = @data_api.writable_fields(primary_key: false)
        attrs = params[@data_api.name].slice(*permitted_fields).to_h
        @resource = @data_api_request.specified_resource ||
                    @data_api_request.resource_collection.build(@data_api.primary_key => @data_api_request.specified_resource_id)
        @resource.assign_attributes(Hash[permitted_fields.map { |attr| [attr, nil] }])
        @resource.assign_attributes(attrs)

        if @resource.persisted?
          status 200
        else
          status 201
        end

        if @resource.save
          render rabl: 'data_api'
          return
        else
          error!({ error: 400, description: "#{@resource.errors.full_messages.join(', ')}" }, 400)
        end

      # DELETE requests, deletes resource
      when 'DELETE'

        # deleting scoped resource collection
        if @data_api_request.specified_resource_id.blank?
          @resource = @data_api_request.resource_collection
          @resource = filter(@resource)

          if @resource.destroy_all
            status 204
            return
          else
            error! 400, 400
          end

        # deleting specified resources
        elsif @data_api_request.specified_resource.present?
          @resource = @data_api_request.specified_resource

          # deleting multiple resources
          if @resource.is_a?(Array) || @resource.is_a?(ActiveRecord::Relation)
            begin
              ActiveRecord::Base.transaction do
                @resource.each(&:destroy!)
              end
            rescue
              error! 400, 400
            end

            status 200
            render rabl: 'data_api'
            return

          # deleting a single resource
          else
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
      end
    end

    error! 404, 404
  end
end
