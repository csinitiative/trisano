# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
# config.action_view.cache_template_extensions         = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# Reload the csv module
# Dependencies.explicitly_unloadable_constants << 'Export::Csv'
# Dependencies.explicitly_unloadable_constants << 'Routing::State'

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
if TRISANO_LOG_LOCATION.split('').last != '/'
  TRISANO_LOG_LOCATION = TRISANO_LOG_LOCATION + '/'
end
default_appender = Logging::Appenders::RollingFile.new 'default', :filename => TRISANO_LOG_LOCATION + 'trisano.log', :age => 'daily', :keep => 10, :safe => true, :layout => layout

DEFAULT_LOGGER = Logging::Logger['server']
DEFAULT_LOGGER.add_appenders default_appender

if ENV['TRISANO_LOG_LEVEL'] != nil
  DEFAULT_LOGGER.level = ENV['TRISANO_LOG_LEVEL'].intern
else
  DEFAULT_LOGGER.level = :debug
end

config.logger = DEFAULT_LOGGER
