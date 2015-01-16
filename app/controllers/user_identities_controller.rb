class UserIdentitiesController < ApplicationController
  before_action :authenticate_user!

  def index
    @identities = current_user.identities
    @identities = EmailPattern.all
    respond_to do |format|
      format.json { asdf;render json: @identities }
    end
  end
end
