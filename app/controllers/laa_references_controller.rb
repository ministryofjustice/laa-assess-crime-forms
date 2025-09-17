class LaaReferencesController < ActionController::Base
  def index
    @results = Payments::LaaReferenceResults.new.call(:payments, params[:query], params[:total_results])
    respond_to do |format|
      format.json { render json: @results }
    end

    expires_in 5.minutes
  end
end

