class DashboardsController < ApplicationController
  before_action :authorize_supervisor

  layout 'dashboard'

  def show
    if nav_select == 'search'
      @search_form = SearchForm.new(search_params)
      @search_form.execute if @search_form.valid?
    else
      load_overview
    end
  end

  def new
    @search_form = SearchForm.new(default_params)
    load_overview unless nav_select == 'search'
    render :show
  end

  def nav_select
    @nav_select ||= controller_params.fetch(:nav_select, 'prior_authority')
  end

  def authorize_supervisor
    authorize :dashboard, :show?
    redirect_to root_path unless FeatureFlags.insights.enabled?
  end

  private

  def load_overview
    dashboard_ids = get_dashboard_ids(nav_select)
    @iframe_urls = generate_metabase_urls(dashboard_ids)
  end

  def controller_params
    params.permit(:nav_select)
  end

  def check_controller_params
    param_model = Nsm::DashboardsParams.new(controller_params)
    raise param_model.error_summary.to_s unless param_model.valid?
  end

  def search_params
    params.require(:search_form).permit(
      :query,
      :submitted_from,
      :submitted_to,
      :updated_from,
      :updated_to,
      :status_with_assignment,
      :caseworker_id,
      :sort_by,
      :sort_direction,
      :application_type,
      :high_value
    ).merge(default_params)
  end

  def default_params
    {
      page: params.fetch(:page, '1'),
    }
  end

  def get_dashboard_ids(nav_select)
    # the else condition can never be reached because of param validation
    if nav_select == 'prior_authority'
      ids = ENV.fetch('METABASE_PA_DASHBOARD_IDS')&.split(',')
    elsif nav_select == 'nsm'
      ids = ENV.fetch('METABASE_NSM_DASHBOARD_IDS')&.split(',')
    else
      # :nocov:
      false
      # :nocov:
    end
    ids || []
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
end
