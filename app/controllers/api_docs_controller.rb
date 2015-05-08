class APIDocsController < ApplicationController
  layout '../api_docs/_layout'

  def explore
    @api_explorer_app = OAuthApplication.explorer_app

    if current_user.present?
      @access_token = Doorkeeper::AccessToken.find_or_create_for(@api_explorer_app, current_user.id, 'public', 1200, false).token
    end
  end
end
