class LaaReferencesController < ApplicationController
  def search
    authorize(:payment, :update?)
    results = Payments::LaaReferenceResults.new.call(params[:query], params[:total_results])
    respond_to do |format|
      format.json { render json: results }
    end
  end
end
