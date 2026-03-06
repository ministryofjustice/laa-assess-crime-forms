module Payments
  class CourtsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def index
      respond_to do |format|
        format.json { render json: courts }
      end

      expires_in 60.minutes
    end

    private

    def courts
      LaaCrimeFormsCommon::Court.all.map(&:as_json)
    end
  end
end
