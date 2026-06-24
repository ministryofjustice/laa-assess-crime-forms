class MetabaseController < ApplicationController
  # :nocov:
  def show
    dashboard_ids = [47]
    @iframe_urls = generate_metabase_urls(dashboard_ids)
  end

  private

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
