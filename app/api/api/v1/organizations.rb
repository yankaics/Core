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

      fieldset_for :organization

      inclusion_for :organization

      @organization = Organization.all
    end
  end
end
