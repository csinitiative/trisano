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

layout = Logging::Layouts::Pattern.new :pattern => "[%d] [%-5l] %m\n"

# Default logfile, history kept for 10 days
TRISANO_LOG_LOCATION = ENV['TRISANO_LOG_LOCATION'] ||= '/var/log/trisano/'
default_appender = Logging::Appenders::RollingFile.new 'default', :filename => TRISANO_LOG_LOCATION + 'trisano.log', :age => 'daily', :keep => 10, :safe => true, :layout => layout

#DEFAULT_LOGGER = returning Logging::Logger['server'] do |l|
#  l.add_appenders default_appender
#end
DEFAULT_LOGGER = Logging::Logger['server']
DEFAULT_LOGGER.add_appenders default_appender
DEFAULT_LOGGER.level = :info

