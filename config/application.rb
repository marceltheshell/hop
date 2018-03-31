require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"
require "./app/middleware/catch_json_parse_errors.rb"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module HopServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << "#{Rails.root}/lib"


    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    #
    # Default timezone
    #
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc

    #
    # Generator configs
    #
    config.generators do |g|
      g.helper false
      g.assets false
      g.views false #no vies
      g.jbuilder false # no jbuilders
      g.test_framework :test_unit, fixture: false
      # g.orm :active_record, primary_key_type: :uuid
    end

    #
    # Custom configs
    #
    config.settings = config_for(:settings)

    #
    # background processing
    #
    config.active_job.queue_adapter = :sidekiq

    # config.middleware.use CatchJsonParseErrors
    config.middleware.insert_before Rack::Head, CatchJsonParseErrors
  end
end
