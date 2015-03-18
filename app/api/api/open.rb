class API::Open < API
  include APIGuard
  include APIResourceFieldsettable
  include APIResourceIncludable

  route :any, '*path' do
    @request_path = params.path
    # remove format extension in path
    @request_path.slice!(/\..+$/)
    # remove versioning in path
    @request_path.slice!(/^v1\//)

    if false

    # Find if there is a matching DataAPI
    elsif (@data_api = DataAPI.find_by_path(@request_path)).present?
      @resource_name = @data_api.name.to_sym
      @resource_columns = @data_api.columns
      @resource_primary_key = @data_api.primary_key
      fieldset_for @resource_name, permitted_fields: @resource_columns,
                                   show_all_permitted_fields_by_default: true,
                                   root: true
      # inclusion_for @resource_name, root: true
      resource_collection = @data_api.data_model.select(fieldset(@resource_name) + [@resource_primary_key])

      # If getting a single resourse
      if @data_api.single_data_id.present?
        if (@resource = resource_collection.find_by(@resource_primary_key => @data_api.single_data_id)).present?
          render rabl: 'data_api'
          return
        end

      # If getting a resourse collection
      else
        @resources = resource_collection.all
        render rabl: 'data_apis'
        return
      end
    end

    error! 404
  end
end
