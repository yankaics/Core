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
      fields = (params[:fields].is_a? Hash) ? params[:fields] : { user: params[:fields] }
      @user_fields = fields[:user] ? fields[:user].split(',').map(&:to_sym) : []
      @user_include = params[:include] ? params[:include].split(',').map(&:to_sym) : []
      @organization_fields = fields[:organization] ? fields[:organization].split(',').map(&:to_sym) : []
      @user = User.includes(:data).last
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
