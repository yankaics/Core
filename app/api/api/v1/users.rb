class API::V1::Users < API::V1
  rescue_from :all

  resources :users, desc: "Get user data" do
    desc "Get data of users", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
      NOTE
    }
    params do
      optional :per_page, desc: APIHelper::Paginatable.per_page_param_desc, type: :integer
      optional :page, desc: APIHelper::Paginatable.page_param_desc, type: :integer
      optional :sort, desc: APIHelper::Sortable.sort_param_desc
      optional :'filter[id]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'id')
      optional :'filter[uuid]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'uuid')
      optional :'filter[username]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'username')
      optional :'filter[name]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'name')
      optional :'filter[email]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'email')
      optional :'filter[sign_in_count]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'sign_in_count')
      optional :'filter[created_at]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'created_at')
      optional :'filter[updated_at]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'updated_at')
      optional :'filter[last_sign_in_at]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'last_sign_in_at')
      optional :'filter[fbid]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'fbid')
      optional :'filter[fbemail]', desc: APIHelper::Filterable.filter_param_desc(for_field: 'fbemail')
      optional :fields, desc: "Return only specific fields in resource object."
      optional :include, desc: "Returning compound documents that include specific associated objects."
    end
    get rabl: 'user' do
      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS

      # Applications with direct data access permitted can access all data from the user
      # (using their application access token)
      if current_application.present? &&
         current_application.allow_direct_data_access &&
         current_user.blank?
        permitted_attrs += User::EMAIL_ATTRS
        permitted_attrs += User::ACCOUNT_ATTRS
        permitted_attrs += User::FB_ATTRS
        permitted_attrs += User::INFO_ATTRS
        permitted_attrs += User::IDENTITY_ATTRS
        permitted_attrs += User::CORE_ATTRS
      end

      fieldset_for :user, default: true, permitted_fields: permitted_attrs,
                          defaults_to_permitted_fields: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, default: true

      @users = filter(User.all, filterable_fields: permitted_attrs)
      sortable
      pagination @users.size

      @users = @users.order(sortable_sort).page(pagination_page).per(pagination_per_page)
    end

    desc "Get data of a user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
      NOTE
    }
    params do
      requires :id, type: Integer, desc: "User ID."
      optional :fields, desc: "Return only specific fields in resource object."
      optional :include, desc: "Returning compound documents that include specific associated objects."
    end
    get :':id', rabl: 'user' do
      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS

      # Applications with direct data access permitted can access all data from the user
      # (using their application access token)
      if current_application.present? &&
         current_application.allow_direct_data_access &&
         current_user.blank?
        permitted_attrs += User::EMAIL_ATTRS
        permitted_attrs += User::ACCOUNT_ATTRS
        permitted_attrs += User::FB_ATTRS
        permitted_attrs += User::INFO_ATTRS
        permitted_attrs += User::IDENTITY_ATTRS
        permitted_attrs += User::CORE_ATTRS
      end

      fieldset_for :user, default: true, permitted_fields: permitted_attrs,
                          defaults_to_permitted_fields: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, default: true

      @user = User.find_by(id: params[:id])

      if @user.blank?
        error!({ error: 404 }, 404)
      end
    end

    desc "Update data for a user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
      NOTE
    }
    params do
      requires :id, type: Integer, desc: "User ID."
      User::EDITABLE_ATTRS.each do |attr|
        optional "user[#{attr}]"
      end
    end
    patch :':id', rabl: 'user' do
      # Only permitted applications can use this API
      # (using their applications access token)
      if current_application.blank? ||
         !current_application.allow_direct_data_access ||
         current_user.present?
        error!({ error: 403 }, 403)
      end

      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS
      permitted_attrs += User::EMAIL_ATTRS
      permitted_attrs += User::ACCOUNT_ATTRS
      permitted_attrs += User::FB_ATTRS
      permitted_attrs += User::INFO_ATTRS
      permitted_attrs += User::IDENTITY_ATTRS
      permitted_attrs += User::CORE_ATTRS

      fieldset_for :user, default: true, permitted_fields: permitted_attrs,
                          defaults_to_permitted_fields: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, default: true

      @user = User.find_by(id: params[:id])

      if @user.blank?
        error!({ error: 404 }, 404)
      end

      ac_params = ActionController::Parameters.new(params)
      user_params = ac_params.require(:user).permit(*User::EDITABLE_ATTRS)

      # translate enums
      if user_params[:gender].present?
        case user_params[:gender]
        when 'male'
          user_params[:gender] = 1
        when 'female'
          user_params[:gender] = 2
        when 'other'
          user_params[:gender] = 3
        when 'unspecified'
          user_params[:gender] = 0
        else
          error! "'#{user_params[:gender]}' is not a valid gender. Valid genders are: 'male' ,'female', 'other' or 'unspecified'.", 400
        end
      end

      begin
        @user.update!(user_params)
      rescue StandardError => e
        error!({ error: e.to_s }, 400)
      end

      @user
    end

    desc "Send notifications to users", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        This API is accessible only with app tokens, with apps that have direct data access.
      NOTE
    }
    params do
      requires :id, desc: "User ID."
      optional :'notification[subject]', desc: "Notification subject"
      optional :'notification[message]', desc: "Notification main message"
      optional :'notification[url]', desc: "Notification link URL"
      optional :'notification[payload]', desc: "Notification payload"
      optional :'notification[push]', desc: "Send push notifications or not? (for permitted apps only)"
      optional :'notification[email]', desc: "Send email notifications or not? (for permitted apps only)"
      optional :'notification[sms]', desc: "Send SMS notifications or not? (for permitted apps only)"
      optional :'notification[fb]', desc: "Send Facebook notifications or not? (for permitted apps only)"
    end
    post :':id/notifications', rabl: 'notification' do
      # Only permitted applications can use this API
      # (using their applications access token)
      if current_application.blank? ||
         !current_application.allow_direct_data_access ||
         current_user.present?
        error!({ error: 403 }, 403)
      end

      params.id = params.id && params.id.to_s
      ac_params = ActionController::Parameters.new(params)

      if multiget?(param: :id)
        @users = multiget(User, find_by: :id, param: :id, max: 1000)
        @notifications = @users.map do |user|
          notification = user.notifications.build(ac_params.require(:notification).permit(:subject, :message, :url, :payload, :push, :email, :sms, :fb))

          notification.application = current_application

          if notification.save
            status 201
          else
            error!({ error: 400, description: "#{@notification.errors.full_messages.join(', ')}" }, 400)
          end

          notification
        end

      else
        @user = multiget(User, find_by: :id, param: :id, max: 1)
        @notification = @user.notifications.build(ac_params.require(:notification).permit(:subject, :message, :url, :payload, :push, :email, :sms, :fb))

        @notification.application = current_application

        if @notification.save
          status 201
        else
          error!({ error: 400, description: "#{@notification.errors.full_messages.join(', ')}" }, 400)
        end
      end
    end
  end
end
