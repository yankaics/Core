class PagesController < ApplicationController
  layout '_base', only: [:mobile_index]

  def index

  end

  def mobile_index

  end

  def eula
    @eula = Settings[:site_eula]
  end

  def sst
    render text: SignonStatusTokenService.generate(current_user)
  end

  def rsa_public_key
    render text: CoreRSAKeyService.public_key_string
  end
end
