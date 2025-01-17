module About
  class PrivacyController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :skip_authorization

    def index; end

    private

    def controller_params
      false
    end
  end
end
