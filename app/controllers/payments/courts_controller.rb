module Payments
  class CourtsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_after_action :verify_authorized

    def index
      respond_to do |format|
        format.json { render json: courts }
      end
    end

    private

    def courts
      @courts ||= Rails.cache.fetch('courts', expires_in: 5.minutes) do
        LaaCrimeFormsCommon::Court.all.map(&:as_json)
      end
    end
  end
end
