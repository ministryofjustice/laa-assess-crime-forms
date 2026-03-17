module Payments
  class CourtsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def index
      expires_in 24.hours

      respond_to do |format|
        format.json { render json: courts }
      end
    end

    private

    def courts
      LaaCrimeFormsCommon::Court.all.map(&:as_json)
    end
  end
end
