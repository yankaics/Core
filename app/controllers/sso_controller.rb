class SSOController < ApplicationController
  include RedirectCheckingHelper

  # Refresh the sign-on status token (sst) in cookie
  def refresh_sst
    refresh_signon_status_token

    check_redirect_to

    if can_redirect
      redirect_to redirect_url
    else
      redirect_to root_path
    end
  end

  # GET the SST
  def get_sst
    render text: SignonStatusTokenService.generate(current_user)
  end

  # GET the RSA public key
  def get_rsa_public_key
    render text: CoreRSAKeyService.public_key_string
  end
end
