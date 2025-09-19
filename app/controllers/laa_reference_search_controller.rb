class LaaReferenceSearchController < ApplicationController
  def index
    authorize(:payment, :update?)
    results = Payments::LaaReferenceResults.new.call(params[:query], params[:total_results])
    respond_to do |format|
      format.json { render json: results }
    end

    expires_in 5.minutes
  end
end
