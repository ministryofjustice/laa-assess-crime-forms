Rails.application.config.after_initialize do
  Auth::Configuration.validate!
end
