module RedirectCheckingHelper
  extend ActiveSupport::Concern

  included do
    attr_accessor :can_redirect, :redirect_url, :redirect_url_query, :redirect_url_uri
  end

  def check_redirect_to
    core_domain = CoreRSAKeyService.domain
    self.redirect_url = params[:redirect_to] || request.env["HTTP_REFERER"]

    return unless redirect_url

    self.redirect_url_uri = URI.parse(redirect_url)
    self.redirect_url_query = redirect_url_uri.query ? URI.decode_www_form(redirect_url_uri.query) : []
    self.redirect_url_query = redirect_url_query << ['flash[notice]', flash[:notice]]
    self.redirect_url_query = redirect_url_query << ['flash[alert]', flash[:alert]]
    self.redirect_url_uri.query = URI.encode_www_form(redirect_url_query)
    self.redirect_url = redirect_url_uri.to_s

    self.can_redirect = redirect_url && redirect_url_uri.host.ends_with?(core_domain)
  end
end
