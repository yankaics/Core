class API::V1::Notifications < API::V1
  rescue_from ActionController::ParameterMissing do |e|
    error!({ error: e.to_s }, 400)
  end

  resources :notifications, desc: "Send Notifications" do

    desc "Get notifications", {
      http_codes: APIGuard.access_token_error_codes,
      notes: <<-NOTE
        This API is accessible only with app tokens, with apps that have direct data access.
      NOTE
    }
    params do
      optional :per_page, desc: APIHelper::Paginatable.per_page_param_desc, type: :integer
      optional :page, desc: APIHelper::Paginatable.page_param_desc, type: :integer
      optional :sort, desc: APIHelper::Sortable.sort_param_desc
      optional :fields, desc: APIHelper::Fieldsettable.fields_param_desc(example: 'type,name,device_id')
    end
    get :notifications, rabl: 'notification' do
      # Applications with direct data access permitted can use this API
      # (using their application access token)
      if current_application.present? &&
         current_application.allow_direct_data_access &&
         current_user.blank?

        fieldset_for :notification, default: true

        @notifications = Notifications.all

        sortable default_order: { created_at: :desc }
        pagination @notifications.size

        @notifications = @notifications.order(sortable_sort).page(pagination_page).per(pagination_per_page)
      else
        error!({ error: 403 }, 403)
      end
    end
  end
end
