class RobotsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    if ENV.fetch('ALLOW_INDEXING', false) == 'true'
      render :allow
    else
      render :disallow
    end
  end
end
