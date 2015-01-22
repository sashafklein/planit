require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Planit
  class Application < Rails::Application

    config.action_controller.asset_host = ENV['ASSET_PATH']

    config.i18n.enforce_available_locales = true

    config.active_record.default_timezone = :utc

    config.generators do |g|
      g.helper false
      g.javascript_engine false
      g.request_specs false
      g.routing_specs false
      g.model_specs false
      g.decorator_specs false
      g.factories false
      g.mailer_specs false
      g.view_specs false
      g.stylesheets false
      g.test_framework :rspec
      g.factory_girl false
    end

    config.action_mailer.default_url_options = { :host => "www.plan.it" }

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      :port           => '587',
      :address        => 'smtp.sendgrid.net',
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :domain         => 'heroku.com',
      :enable_starttls_auto => true
    }

    config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir[
      "#{config.root}/lib/**/",
      "#{config.root}/app/validators/"
    ]

    # https://github.com/drapergem/draper/issues/644 
    require 'draper'
    Draper::Railtie.initializers.delete_if {|initializer| initializer.name == 'draper.setup_active_model_serializers' }

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
