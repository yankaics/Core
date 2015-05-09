# Make grape-swagger docs extendable by
# overriding getters of combined_routes, combined_namespaces... etc.
module APIDocsExtended
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def prepended_namespaces
      {}
    end

    def prepended_namespace_routes
      {}
    end

    def appended_namespaces
      data_api_combined_namespaces
    end

    def appended_namespace_routes
      data_api_combined_namespace_routes
    end

    def combined_namespace_routes
      prepended_namespace_routes.merge(
        @combined_namespace_routes.merge(appended_namespace_routes)
      )
    end

    def combined_namespaces
      prepended_namespaces.merge(
        @combined_namespaces.merge(appended_namespaces)
      )
    end

    def data_apis(org_code = nil)
      if org_code
        DataAPI.public_accessible.order(:name).where(organization_code: org_code)
      else
        DataAPI.public_accessible.order(:name).global
      end
    end

    def data_api_combined_namespaces(org_code = nil)
      data_apis = data_apis(org_code)
      namespaces = {}

      data_apis.each do |data_api|
        data_api_description = data_api.description.present? ? data_api.description : "Open #{data_api.name} data API"
        opts = {
          desc: data_api_description,
          notes: data_api.notes
        }

        namespaces[data_api.name] = Grape::Namespace.new(data_api.name, opts)
      end

      namespaces
    end

    def data_api_combined_namespace_routes(org_code = nil)
      data_apis = data_apis(org_code)
      routes = {}

      data_apis.each do |data_api|
        data_api_description = data_api.description.present? ? data_api.description : data_api.name
        collection_opts = {
          params: {
            per_page: { required: false, type: 'Integer', desc: "The number of #{data_api_description.try(:pluralize)} to return per page, defaults to 20 and up to a maximum of 100." },
            page: { required: false, type: 'Integer', desc: "Specify further page of data to retrieve, defaults to 1." },
            sort: { required: false, type: 'String', desc: APIResourceSortable.sort_param_desc(default: data_api.default_order, example: data_api.schema.keys.sample(2).map { |s| ['-', ''].sample + s }.join(',')) },
            fields: { required: false, type: 'String', desc: APIResourceFieldsettable.fields_param_desc(example: data_api.schema.keys.sample(3).join(',')) },
            callback: { required: false, type: 'String', desc: "JSON-P callbacks, wrap the results in a specific JSON function." }
          },
          http_codes: [],
          description: "Get data of #{data_api_description.try(:pluralize)}",
          notes: data_api.notes,
          method: 'GET',
          path: "/#{data_api.path}(.:format)"
        }

        singular_resource_opts = {
          params: {
            data_api.primary_key => { required: true, type: 'String', desc: "The #{data_api.primary_key} of #{data_api_description}." },
            fields: { required: false, type: 'String', desc: APIResourceFieldsettable.fields_param_desc(example: data_api.schema.keys.sample(3).join(',')) },
            callback: { required: false, type: 'String', desc: "JSON-P callbacks, wrap the results in a specific JSON function." }
          },
          http_codes: [
            [404, "Not Found: that #{data_api_description} does not exists."]
          ],
          description: "Get data of an #{data_api_description}",
          notes: data_api.notes,
          method: 'GET',
          path: "/#{data_api.path}/:#{data_api.primary_key}(.:format)",
          callback: { required: false, type: 'String', desc: "" }
        }

        collection_route = Grape::Route.new(collection_opts)
        singular_resource_route = Grape::Route.new(singular_resource_opts)

        routes[data_api.name] = [collection_route, singular_resource_route]
      end

      routes
    end
  end
end
