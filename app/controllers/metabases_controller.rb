class MetabasesController < ApplicationController
  before_action :authorize_supervisor

  # :nocov:
  def show
    dashboard_ids = [47]
    @iframe_urls = generate_metabase_urls(dashboard_ids)
    return unless params[:card_id].present? && params[:start_date].present? && params[:end_date].present?

    download_report
  end

  private

  def authorize_supervisor
    authorize :dashboard, :show?
    redirect_to root_path unless FeatureFlags.insights.enabled?
  end

  def download_report
    csv = MetabaseClient.new.download_question(params[:card_id], params[:start_date], params[:end_date])

    send_data(
      csv,
      filename: "metabase-report-#{Date.current}.csv",
      type: 'text/csv; charset=utf-8',
      disposition: 'attachment'
    )
  end

  def generate_metabase_urls(ids)
    ids.map do |id|
      payload = {
        resource: { dashboard: id.to_i },
        params: {},
        exp: Time.now.to_i + (60 * 60) # After an hour, using in-dashboard widgets will stop working
      }
      token = JWT.encode(payload, ENV.fetch('METABASE_SECRET_KEY'))

      "#{ENV.fetch('METABASE_SITE_URL')}/embed/dashboard/#{token}#bordered=true&titled=true"
    end
  end
  # :nocov:
end
