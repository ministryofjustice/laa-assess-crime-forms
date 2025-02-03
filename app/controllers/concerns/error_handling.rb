module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      raise unless ENV.fetch('RAILS_ENV', nil) == 'production'

      report_error(exception)
    end
  end
end
