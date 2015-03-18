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
        @resources = resource_collection.order(@data_api.default_order).page(params[:page] || 1).per(params[:per_page] || 20)

        page_size = @resources.size
        total_count = @resources.total_count
        pages_count = (total_count + page_size - 1) / page_size
        current_page = (params[:page] || 1).to_i
        header_links ||= []

        if current_page < pages_count
          header_links << "<#{request.url.add_or_replace_uri_param(:page, current_page + 1)}>; rel=\"next\""
          header_links << "<#{request.url.add_or_replace_uri_param(:page, pages_count)}>; rel=\"last\""
        end
        if current_page > 1
          header_links << "<#{request.url.add_or_replace_uri_param(:page, (current_page > pages_count ? pages_count : current_page - 1))}>; rel=\"prev\""
          header_links << "<#{request.url.add_or_replace_uri_param(:page, 1)}>; rel=\"first\""
        end

        header 'Link', header_links.join(', ')
        render rabl: 'data_apis'
        return
      end
    end

    error! 404
  end
end
