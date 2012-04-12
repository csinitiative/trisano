# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

require 'logging'

# Logging.init is required to avoid 
#   unknown level was given 'info' (ArgumentError)
# or
#   uninitialized constant Logging::MAX_LEVEL_LENGTH (NameError)
# when an Appender or Layout is created BEFORE any Logger is instantiated:
Logging.init :debug, :info, :warn, :error, :fatal

# see https://github.com/TwP/logging/blob/master/lib/logging/layouts/pattern.rb
# for pattern formatting reference
layout = Logging::Layouts::Pattern.new :pattern => "[%p] [%d] [%-5l] %m\n"

# Default logfile, history kept for 10 days
TRISANO_LOG_LOCATION = ENV['TRISANO_LOG_LOCATION'] ||= '/var/log/trisano/'
if TRISANO_LOG_LOCATION.split('').last != '/'
  TRISANO_LOG_LOCATION = TRISANO_LOG_LOCATION + '/'
end
default_appender = Logging::Appenders::RollingFile.new 'default', :filename => TRISANO_LOG_LOCATION + 'trisano.log', :age => 'daily', :keep => 10, :safe => true, :layout => layout

DEFAULT_LOGGER = Logging::Logger['server']
DEFAULT_LOGGER.add_appenders default_appender
if ENV['TRISANO_LOG_LEVEL'] != nil
  DEFAULT_LOGGER.level = ENV['TRISANO_LOG_LEVEL'].intern
else
  DEFAULT_LOGGER.level = :info
end

config.logger = DEFAULT_LOGGER

require 'redis-store'
config.gem 'redis-store'
require 'site_config'
Rails.configuration.cache_store = :redis_store, { :host => config_option(:redis_server) }
