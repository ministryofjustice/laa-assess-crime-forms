require Rails.root.join('app/lib/host_env')
require Rails.root.join('app/lib/feature_flags')
require Rails.root.join('app/lib/omni_auth/strategies/dev_auth')

# rubocop:disable Metrics/BlockLength
Devise.setup do |config|
  require 'devise/orm/active_record'

  # Explicitly set this here to avoid deprecation warning in Rails 7.1. See https://github.com/heartcombo/devise/issues/5644
  config.secret_key = Rails.application.secret_key_base

  # Configure which authentication keys should be case-insensitive.
  # These keys will be downcased upon creating or modifying a user and when used
  # to authenticate or find a user. Default is :email.
  config.case_insensitive_keys = [:none]

  # ==> Configuration for :timeoutable
  # The time you want to timeout the user session without activity. After this
  # time the user will be asked for credentials again. Default is 30 minutes.
  config.timeout_in = Rails.configuration.x.auth.timeout_in

  # ==> Navigation configuration
  # Lists the formats that should be treated as navigational. Formats like
  # :html should redirect to the sign in page when the user does not have
  # access, but formats like :xml or :json, should return 401.
  #
  # If you have any extra navigational formats, like :iphone or :mobile, you
  # should add them to the navigational formats lists.
  #
  # The "*/*" below s required to match Internet Explorer requests.
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # When using OmniAuth, Devise cannot automatically set OmniAuth path,
  # so you need to do it manually. For the users scope, it would be:
  # config.omniauth_path_prefix = '/auth'

  config.sign_out_via = :get

  # ==> OmniAuth
  # Add a new OmniAuth provider. Check the wiki for more information on setting
  # up on your models and hooks.
  #
  # Uses the DevAuth strategy if local/docker env and feature flag for dev_auth is true

  if !(HostEnv.local? || ENV.key?('IS_LOCAL_DOCKER_ENV')) && FeatureFlags.dev_auth.enabled?
    raise 'The DevAuth strategy must not be used in this environment'
  end

  strategy_class = FeatureFlags.dev_auth.enabled? ? OmniAuth::Strategies::DevAuth : OmniAuth::Strategies::OpenIDConnect

  config.omniauth(
    :openid_connect,
    {
      name: :azure_ad,
      scope: [:openid, :email],
      response_type: :code,
      client_options: {
        identifier: ENV.fetch('OMNIAUTH_AZURE_CLIENT_ID', nil),
        secret: ENV.fetch('OMNIAUTH_AZURE_CLIENT_SECRET', nil),
        redirect_uri: ENV.fetch('OMNIAUTH_AZURE_REDIRECT_URI', nil)
      },
      discovery: true,
      pkce: true,
      issuer: "https://login.microsoftonline.com/#{ENV.fetch('OMNIAUTH_AZURE_TENANT_ID', nil)}/v2.0",
      strategy_class: strategy_class
    }
  )

  OmniAuth.config.logger = Rails.logger
end
# rubocop:enable Metrics/BlockLength
