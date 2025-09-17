class LaaReferencesController < ActionController::Base
  protect_from_forgery with: :exception

  def create
    @results = Payments::LaaReferenceResults.new.call(:payments, params[:query], params[:total_results])
    respond_to do |format|
      format.json { render json: @results }
    end

    expires_in 5.minutes
  end
end

