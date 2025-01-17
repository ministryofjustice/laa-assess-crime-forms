class HomeController < ApplicationController
  before_action :skip_authorization

  private

  def controller_params; end
end
