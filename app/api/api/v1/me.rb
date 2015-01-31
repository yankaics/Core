class API::V1::Me < API::V1
  # rescue_from :all
  guard_all!

  resource :me, desc: "Operations about the current user" do
    desc "Get data of the current user", {
      http_codes: [
        [401, "Unauthorized: missing or bad access token."],
        [403, "Forbidden: the access token you hand over doesn't give the power you requested."]
      ],
      notes:  <<-NOTE
        Requires OAuth access token.
      NOTE
    }
    params do
      optional :fields, desc: "Return only specific fields in resource object."
      optional :include, desc: "Returning compound documents that include specific associated objects."
    end
    get "/", rabl: 'user' do
      permitted_attrs = []
      permitted_attrs += User::PUBLIC_ATTRS if scopes.include? :public
      permitted_attrs += User::EMAIL_ATTRS if scopes.include? :email
      permitted_attrs += User::ACCOUNT_ATTRS if scopes.include? :account
      permitted_attrs += User::FB_ATTRS if scopes.include? :fb
      permitted_attrs += User::INFO_ATTRS if scopes.include? :info
      permitted_attrs += User::IDENTITY_ATTRS if scopes.include? :identity
      permitted_attrs += User::CORE_ATTRS if current_app.core_app?

      fieldset_for :user, root: true, permitted_fields: permitted_attrs,
                          show_all_permitted_fields_by_default: true
      fieldset_for :user_identity
      fieldset_for :user_email
      fieldset_for :organization
      fieldset_for :department

      inclusion_for :user

      @user = current_user
    end

    get "/emails", rabl: 'user_email' do
      guard! scopes: ['identity']
      @user_email = current_user.emails
    end

    get "/identities", rabl: 'user_identity' do
      guard! scopes: ['identity']
      @user_identity = current_user.identities
    end
  end

  desc "Simulate errors"
  params do
    optional :code, type: Integer, default: 404
  end
  get "error" do
    error!(params[:code], params[:code])
  end
end
