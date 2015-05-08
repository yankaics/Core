class APIDocsController < ApplicationController
  layout '../api_docs/_layout'

  def explore
    request_url = URI.parse(request.url)
    swagger_url = URI.parse(request.url)
    if request_url.host.match(/^api\./)
      swagger_url.path = '/docs'
    else
      swagger_url.path = '/api/docs'
    end
    @swagger_url = swagger_url.to_s
    @api_explorer_app = OAuthApplication.explorer_app
    @all_scopes = OAuthAccessToken.scopes
    @applications = { api_docs_api_explorer: { name: 'API Explorer' } }

    if current_user.present?
      @access_token = Doorkeeper::AccessToken.find_or_create_for(@api_explorer_app, current_user.id, 'public', 1200, false).token

      user_apps = Hash[current_user.oauth_applications.select(:id, :name, :uid).map do |app|
        [app.uid, { name: app.name }]
      end]

      @applications.merge!(user_apps)
    end
  end

  def explorer_oauth_callbacks
    render layout: false
  end
end
