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
      optional :fields, desc: APIResourceFieldsettable.fields_param_desc(example: 'id,uuid,name,avatar_url')
      optional :include, desc: APIResourceIncludable.include_param_desc(example: 'organization,primary_identity')
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

      fieldset_for :user, root: true, permitted_fields: permitted_attrs,
                          show_all_permitted_fields_by_default: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user, root: true

      @user = current_user
    end

    desc "Get emails of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'identity')}
      NOTE
    }
    get :emails, rabl: 'user_email' do
      guard! scopes: ['identity']
      @user_email = current_user.emails
    end

    desc "Get identities of the current user", {
      http_codes: APIGuard.access_token_error_codes,
      notes:  <<-NOTE
        #{APIGuard.access_token_required_note(scope: 'identity')}
      NOTE
    }
    get :identities, rabl: 'user_identity' do
      guard! scopes: ['identity']
      @user_identity = current_user.identities
    end
  end
end
