class PagesController < ApplicationController
  layout '_base', only: [:mobile_index]

  def index
    @service_navigations = ServiceNavigation.where(visible: true, show_on_index: true).order(index_order: :asc).limit(20)
    @all_service_navigations = ServiceNavigation.where(visible: true, opened: true).order(:order).limit(100)
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
