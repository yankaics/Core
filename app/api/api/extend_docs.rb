# Documentation for extended APIs

class API::ExtendDocs < API
  # include APIExtendDocs

  # documentation_settings = {
  #   base_path: ->(req) { req.host.match(/^api\./) ? '/' : '/api' },
  #   api_version: 'v1',
  #   mount_path: '/docs',
  #   root_base_path: true,
  #   info: {
  #   }
  # }

  # add_swagger_documentation(documentation_settings)

  helpers do
    def data_api_collection(collection)
      if collection == 'user_extend'
        DataAPI.order(:name).owned_by_user.accessible
      elsif org_match = collection.match(/^org_(?<code>.+)$/)
        org_code = org_match[:code]
        DataAPI.order(:name).where(organization_code: org_code).public_accessible
      else
        DataAPI.order(:name).global.public_accessible
      end
    end
  end

  get do
    header['Access-Control-Allow-Origin']   = '*'
    header['Access-Control-Request-Method'] = '*'

    collection = params[:collection]

    @resource_owned_by_user = true if collection == 'user_extend'

    data_api_routes_array = data_api_collection(collection).map do |data_api|
      resources_name = data_api.description.try(:pluralize) ||
                       data_api.name.try(:pluralize)
      resource_name = data_api.description ||
                      data_api.name
      {
        path: "/#{'me/' if @resource_owned_by_user}#{data_api.path}",
        description: "Get data of#{' the current user\'s' if @resource_owned_by_user} #{resource_name}"
      }
    end.compact

    output = {
      # apiVersion:     api_version,
      swaggerVersion: '1.2',
      # produces:       @@documentation_class.content_types_for(target_class),
      apis:           data_api_routes_array,
      # info:           @@documentation_class.parse_info(extra_info)
    }

    output
  end

  route :any, '*path' do
    header['Access-Control-Allow-Origin']   = '*'
    header['Access-Control-Request-Method'] = '*'

    path = params[:path]

    if path.match(/^me\//)
      @resource_owned_by_user = true
      path.gsub!(/^me\//, '')
    end

    @editable = true if params[:editable]

    data_api = DataAPI.accessible.find_by(path: path)
    error!('Not Found', 404) unless data_api

    if data_api
      resource_path = data_api.path
      resources_name = data_api.description.try(:pluralize) ||
                       data_api.name.try(:pluralize)
      resource_name = data_api.description ||
                      data_api.name

      @editable = true if @resource_owned_by_user &&
                          data_api.owned_by_user? &&
                          data_api.owner_writable?
      owner_foreign_key = data_api.owner_foreign_key

      apis = []

      id_request_params = [
        {
          paramType: :path,
          name: data_api.primary_key,
          description: "The #{data_api.primary_key} of #{resource_name}.",
          type: :string,
          required: true
        }
      ]

      page_request_params = [
        {
          paramType: :query,
          name: 'per_page',
          description: APIHelper::Paginatable.per_page_param_desc,
          type: :integer,
          required: false
        },
        {
          paramType: :query,
          name: 'page',
          description: APIHelper::Paginatable.page_param_desc,
          type: :integer,
          required: false
        }
      ]

      sort_request_params = [
        {
          paramType: :query,
          name: 'sort',
          description: APIHelper::Sortable.sort_param_desc(default: data_api.default_order, example: data_api.schema.keys.sample(2).map { |s| ['-', ''].sample + s }.join(',')),
          type: :string,
          required: false
        }
      ]

      filter_request_params = []
      data_api.columns.each do |column|
        filter_request_params << {
          paramType: :query,
          name: "filter[#{column}]",
          description: APIHelper::Filterable.filter_param_desc(for_field: column),
          type: :string,
          required: false
        }
      end

      fields_request_params = [
        {
          paramType: :query,
          name: 'fields',
          description: APIHelper::Fieldsettable.fields_param_desc(example: data_api.schema.keys.sample(3).join(',')),
          type: :string,
          required: false
        }
      ]

      callback_request_params = [
        {
          paramType: :query,
          name: 'callback',
          description: "JSON-P callbacks, wrap the results in a specific JSON function.",
          type: :string,
          required: false
        }
      ]

      collection_operations = []
      resource_operations = []

      collection_operations << {
        notes: data_api.notes,
        summary: "Get data of#{' the current user\'s' if @resource_owned_by_user} #{resources_name}",
        method: 'GET',
        nickname: "#{data_api.name}-c-GET",
        parameters: (page_request_params +
                    sort_request_params +
                    filter_request_params +
                    fields_request_params +
                    callback_request_params)
      }

      resource_operations << {
        notes: data_api.notes,
        summary: "Get data of an #{resource_name}#{' that belongs to the current user' if @resource_owned_by_user}",
        method: 'GET',
        nickname: "#{data_api.name}-GET",
        parameters: (id_request_params +
                    fields_request_params +
                    callback_request_params)
      }

      if @editable
        data_request_params = []
        data_api.schema.each_pair do |name, attrs|
          next if @resource_owned_by_user && name == owner_foreign_key
          type = attrs['type']
          data_request_params << {
            paramType: :form,
            name: "#{data_api.name}[#{name}]",
            description: nil,
            type: (type == 'text' || type == 'datetime') ? :string : type,
            required: !!attrs['required']
          }
        end

        collection_operations << {
          notes: data_api.notes,
          summary: "Create #{resource_name} data#{' for the current user' if @resource_owned_by_user}",
          method: 'POST',
          nickname: "#{data_api.name}-c-POST",
          parameters: (data_request_params +
                      callback_request_params)
        }

        resource_operations << {
          notes: data_api.notes,
          summary: "Update #{resource_name} data#{' for the current user' if @resource_owned_by_user}",
          method: 'PATCH',
          nickname: "#{data_api.name}-PATCH",
          parameters: (id_request_params +
                      data_request_params +
                      callback_request_params)
        }

        resource_operations << {
          notes: data_api.notes,
          summary: "Create or replace #{resource_name} data#{' for the current user' if @resource_owned_by_user}",
          method: 'PUT',
          nickname: "#{data_api.name}-PUT",
          parameters: (id_request_params +
                      data_request_params +
                      callback_request_params)
        }

        resource_operations << {
          notes: data_api.notes,
          summary: "Delete #{resource_name} data#{' for the current user' if @resource_owned_by_user}",
          method: 'DELETE',
          nickname: "#{data_api.name}-DELETE",
          parameters: (id_request_params +
                      data_request_params +
                      callback_request_params)
        }

        collection_operations << {
          notes: data_api.notes,
          summary: "Delete all matched #{resource_name} data#{' for the current user' if @resource_owned_by_user}",
          method: 'DELETE',
          nickname: "#{data_api.name}-c-DELETE",
          parameters: (data_request_params +
                      filter_request_params +
                      callback_request_params)
        }
      end

      apis << {
        path: "/v1/#{'me/' if @resource_owned_by_user}#{data_api.path}.{format}",
        operations: collection_operations
      }

      apis << {
        path: "/v1/#{'me/' if @resource_owned_by_user}#{data_api.path}/{#{data_api.primary_key}}.{format}",
        operations: resource_operations
      }
    end

    api_description = {
      apiVersion:     'v1',
      apis:           apis,
      resourcePath:   "#{'me/' if @resource_owned_by_user}/#{resource_path}",
      basePath:       request.host.match(/^api\./) ? '/' : '/api',
      produces:       ['application/json', 'text/xml'],
      swaggerVersion: '1.2'
    }

    api_description
  end
end
