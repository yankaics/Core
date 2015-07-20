class APIDocsController < ApplicationController
  layout '../api_docs/_layout'

  def explore
    # List of all the API collections
    @api_collections = {
      core: '核心 API',
      extend: '一般 API',
      user_extend: '使用者 API'
    }

    Organization.select(:id, :code, :short_name).order(:code).each do |org|
      @api_collections["org_#{org.code}"] = "#{org.code} - #{org.short_name} API"
    end

    # Get the API collection to be explored
    @api_collection = params[:collection]
    @api_collection ||= 'core'

    request_url = URI.parse(request.url)
    api_base_url = URI.parse(request.url)
    if request_url.host.match(/^api\./)
      api_base_url.path = '/'
    else
      api_base_url.path = '/api/'
    end

    api_base_url.query = nil

    @api_base_url = api_base_url.to_s

    # Get all scopes
    @all_scopes = OAuthAccessToken.scopes

    # Prepare the 'API Explorer' app
    @api_explorer_app = OAuthApplication.explorer_app
    @applications = { api_docs_api_explorer: { name: 'API Explorer' } }

    if current_user.present?
      # Generate an access token for the current user for testing
      @access_token = Doorkeeper::AccessToken.find_or_create_for(@api_explorer_app, current_user.id, 'public', 1200, false).token

      # Get a list of the user owned apps
      user_apps = Hash[current_user.oauth_applications.select(:id, :name, :uid).map do |app|
        [app.uid, { name: app.name }]
      end]

      @applications.merge!(user_apps)
    end

    if current_admin.present? && current_admin.root?
      # Get a list of the core apps
      core_apps = Hash[Doorkeeper::Application.core_apps.select(:id, :name, :uid).map do |app|
        [app.uid, { name: "#{app.name} (Core App)" }]
      end]

      @applications.merge!(core_apps)
    end
  end

  def explorer_oauth_callbacks
    render layout: false
  end
end
