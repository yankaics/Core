class UserIdentitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @identities = current_user.identities
  end
end
