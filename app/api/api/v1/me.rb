class API::V1::Me < API::V1
  # rescue_from :all
  guard_all!

  resource :me, desc: "Operations about the current user" do
    desc "Get data of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note}
      NOTE
    }
    params do
      optional :fields, desc: APIHelper::Fieldsettable.fields_param_desc(example: 'id,uuid,name,avatar_url')
      optional :include, desc: APIHelper::Includable.include_param_desc(example: 'organization,primary_identity')
    end
    get rabl: 'user' do
      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS if scopes.include? :public
      permitted_attrs += User::EMAIL_ATTRS if scopes.include? :email
      permitted_attrs += User::ACCOUNT_ATTRS if scopes.include? :account
      permitted_attrs += User::FB_ATTRS if scopes.include? :facebook
      permitted_attrs += User::INFO_ATTRS if scopes.include? :info
      permitted_attrs += User::IDENTITY_ATTRS if scopes.include? :identity
      permitted_attrs += User::CORE_ATTRS if current_app.present? && current_app.core_app?

      fieldset_for :user, default: true, permitted_fields: permitted_attrs,
                          defaults_to_permitted_fields: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, default: true

      @user = current_user
    end

    desc "Update data of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note}
      NOTE
    }
    params do
      User::EDITABLE_ATTRS.each do |attr|
        optional "user[#{attr}]"
      end
    end
    patch rabl: 'user' do
      guard!(scopes: ['write'])

      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS if scopes.include? :public
      permitted_attrs += User::EMAIL_ATTRS if scopes.include? :email
      permitted_attrs += User::ACCOUNT_ATTRS if scopes.include? :account
      permitted_attrs += User::FB_ATTRS if scopes.include? :facebook
      permitted_attrs += User::INFO_ATTRS if scopes.include? :info
      permitted_attrs += User::IDENTITY_ATTRS if scopes.include? :identity
      permitted_attrs += User::CORE_ATTRS if current_app.present? && current_app.core_app?

      fieldset_for :user, default: true, permitted_fields: permitted_attrs,
                          defaults_to_permitted_fields: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, default: true

      permitted_attrs &= User::EDITABLE_ATTRS

      @user = current_user

      ac_params = ActionController::Parameters.new(params)
      user_params = ac_params.require(:user).permit(*permitted_attrs)

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
        error! e.to_s, 400
      end

      @user
    end

    desc "Get emails of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'identity')}
      NOTE
    }
    params do
      optional :fields, desc: APIHelper::Fieldsettable.fields_param_desc(example: 'email,confirmed_at,created_at')
    end
    get :emails, rabl: 'user_email' do
      guard! scopes: ['identity']
      fieldset_for :user_email, default: true
      @user_email = current_user.emails
    end

    desc "Get identities of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'identity')}
      NOTE
    }
    params do
      optional :fields, desc: APIHelper::Fieldsettable.fields_param_desc
    end
    get :identities, rabl: 'user_identity' do
      guard! scopes: ['identity']
      fieldset_for :user_identity, default: true
      @user_identity = current_user.identities
    end

    desc "Get devices of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes: <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'account')}
      NOTE
    }
    params do
      optional :fields, desc: APIHelper::Fieldsettable.fields_param_desc(example: 'type,name,device_id')
    end
    get :devices, rabl: 'user_device' do
      guard! scopes: ['account']
      fieldset_for :user_device, default: true
      @user_devices = current_user.devices
    end

    desc "Add a device for the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes: <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'write')}
      NOTE
    }
    params do
      optional :'user_device[type]', desc: "Device type, 'ios' or 'android'"
      optional :'user_device[name]', desc: "Device name"
      optional :'user_device[device_id]', desc: "Device ID"
    end
    post :devices, rabl: 'user_device' do
      guard! scopes: ['write']
      ac_params = ActionController::Parameters.new(params)

      @user_device = current_user.devices.build(ac_params.require(:user_device).permit(:type, :name, :device_id))

      if @user_device.save
        status 201
      else
        error!({ error: 400, description: "#{@user_device.errors.full_messages.join(', ')}" }, 400)
      end
    end

    desc "Add or replace a device for the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes: <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'write')}
      NOTE
    }
    params do
      requires :uuid, desc: "Device uuid"
      optional :'user_device[type]', desc: "Device type, 'ios' or 'android'"
      optional :'user_device[name]', desc: "Device name"
      optional :'user_device[device_id]', desc: "Device ID"
    end
    put :'devices/:uuid', rabl: 'user_device' do
      guard! scopes: ['write']
      ac_params = ActionController::Parameters.new(params)

      @user_device = current_user.devices.find_by(uuid: ac_params[:uuid]) ||
                     current_user.devices.build(ac_params.require(:user_device).permit(:type, :name, :device_id))
      @user_device.assign_attributes(ac_params.require(:user_device).permit(:type, :name, :device_id))
      @user_device.uuid = ac_params[:uuid]

      is_new = !@user_device.persisted?
      has_saved = @user_device.save

      if is_new && has_saved
        status 201
      elsif has_saved
        status 200
      else
        error!({ error: 400, description: "#{@user_device.errors.full_messages.join(', ')}" }, 400)
      end
    end

    desc "Remove a device from the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes: <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'write')}
      NOTE
    }
    params do
      requires :uuid, desc: "Device uuid"
    end
    delete :'devices/:uuid', rabl: 'user_device' do
      guard! scopes: ['write']
      ac_params = ActionController::Parameters.new(params)

      @user_device = current_user.devices.find_by(uuid: ac_params[:uuid])

      if @user_device && @user_device.destroy
        status 200
      else
        error!({ error: 400 }, 400)
      end
    end
  end
end
