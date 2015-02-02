class PagesController < ApplicationController

  def index

  end

  def eula
    @eula = Settings[:site_eula]
  end
end
