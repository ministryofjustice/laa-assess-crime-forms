class HomeController < ApplicationController
  before_action :skip_authorization

  private

  def controller_params
    false
  end
end
