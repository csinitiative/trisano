Webrat.configure do |config|
  config.mode = :selenium
  # Selenium defaults to using the selenium environment. Use the following to override this.
  # config.application_environment = :test
end

require 'spec/expectations'
require 'selenium'
require File.expand_path(File.dirname(__FILE__) + '/../../spec/uat/trisano_helper')
include TrisanoHelper

# "before all"
browser = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome", "http://localhost:8080", 15000)

Before do
  @browser = browser
  @browser.start
end

After do
  @browser.stop
end

# "after all"
at_exit do
  browser.close rescue nil
end