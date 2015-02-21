class API::V1::Organizations < API::V1
  # rescue_from :all

  resources :organizations, desc: "Get data about organizations" do
    desc "Get data of all organizations", {
      http_codes: [
        [401, "Unauthorized: missing or bad app credentials."],
        [403, "Forbidden: your app is either blocked or not authorized to access this resource."]
      ],
      notes:  <<-NOTE
      NOTE
    }
    params do
      optional :fields, desc: "Return only specific fields in resource object."
      optional :include, desc: "Returning compound documents that include specific associated objects."
    end
    get rabl: 'organization' do

      fieldset_for :organization, root: true, default_fields: [:code, :name, :short_name]

      inclusion_for :organization, root: true, default_includes: [:departments]
      inclusion_for :department

      scoped_resource = Organization.all

      scoped_resource = scoped_resource.preload(:departments) if fieldset(:organization, :departments)
      scoped_resource = scoped_resource.includes(:departments) if inclusion(:organization, :departments)

      @organization = scoped_resource
    end

    desc "Get data of an organization", {
      http_codes: [
        [401, "Unauthorized: missing or bad app credentials."],
        [403, "Forbidden: your app is either blocked or not authorized to access this resource."]
      ],
      notes:  <<-NOTE
      NOTE
    }
    params do
      requires :code, type: String, desc: "Organization Code."
      optional :fields, desc: "Return only specific fields in resource object."
      optional :include, desc: "Returning compound documents that include specific associated objects."
    end
    get :':code', rabl: 'organization' do

      fieldset_for :organization, root: true, default_fields: [:code, :name, :short_name, :departments]
      fieldset_for :department, default_fields: [:code, :name, :short_name], permitted_fields: [:code, :name, :short_name, :group]

      inclusion_for :organization, root: true, default_includes: [:departments]
      # inclusion_for :department, default_includes: [:departments]

      @organization = Organization.find_by(code: params[:code])
    end
  end
end
