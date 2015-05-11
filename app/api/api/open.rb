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
    @request_path.slice!(/^v1\//)

    # Find if there is a matching TransferAPI
    if false

    # Find if there is a matching DataAPI
    elsif (
      if @request_path.match(/^me\//)
        @me = true
        @data_api = DataAPI.find_by_path(@request_path.gsub(/^me\//, ''), private: true)
      else
        @data_api = DataAPI.find_by_path(@request_path)
      end
    ).present?

      # Guard APIs that belongs to user
      if @me
        guard!(scopes: ['api'])
      end

      @resource_name = @data_api.name.to_sym
      @resource_columns = @data_api.columns
      @resource_primary_key = @data_api.primary_key
      @resource_fields = @resource_columns
      @resource_fields << :id

      # List all the includable fields
      @includable_fields = []
      @includable_fields << :owner if @data_api.has_owner?
      @resource_fields << :owner if @data_api.has_owner?

      fieldset_for @resource_name, permitted_fields: @resource_fields,
                                   show_all_permitted_fields_by_default: true,
                                   root: true
      inclusion_for @resource_name, root: true

      if @data_api.has_owner?
        fieldset_for :user, permitted_fields: User::PUBLIC_ATTRS,
                            show_all_permitted_fields_by_default: true
      end

      # Scope the collection
      select = fieldset(@resource_name)
      fieldset_select = (fieldset(@resource_name) + [@resource_primary_key])
      fieldset_select.delete(:owner)
      fieldset_select << @data_api.owner_foreign_key if @data_api.has_owner? && fieldset(@resource_name).include?(:owner)
      resource_collection = @data_api.data_model.select(fieldset_select)

      # Scope the collection to the current user if needed
      if @me
        case @data_api.owner_primary_key
        when 'uid'
          resource_collection = resource_collection.none if @current_user.organization_code != @data_api.organization_code
          resource_collection = resource_collection.where(@data_api.owner_foreign_key => @current_user.try(@data_api.owner_primary_key))
        else
          resource_collection = resource_collection.where(@data_api.owner_foreign_key => @current_user.try(@data_api.owner_primary_key))
        end
      end

      # If getting a single resourse
      if @data_api.single_data_id.present?
        if (@resource = resource_collection.find_by(@resource_primary_key => @data_api.single_data_id)).present?
          render rabl: 'data_api'
          return
        end

      # If getting a resourse collection
      else
        sortable(default_order: @data_api.default_order)
        pagination resource_collection.size, default_per_page: 20, maxium_per_page: 100

        @resources = resource_collection.order(sort).page(page).per(per_page)

        render rabl: 'data_apis'
        return
      end
    end

    error! 404, 404
  end
end
