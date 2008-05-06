# You don't need to tweak the $LOAD_PATH if you have RSpec and Spec::Ui installed as gems
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../../rspec/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../lib')

require 'rubygems'
require 'spec'
#require 'spec/ui'
require File.dirname(__FILE__) + '/selenium'
#require 'spec/ui/selenium'

Spec::Runner.configure do |config|
  
  nedss_url = ENV['NEDSS_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
  nedss_url = nedss_url.sub("//", "//utah:arches@")
  #nedss_url += "/nedss/cmrs"
  
  config.before(:all) do
    p nedss_url
    @browser = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", nedss_url, 10000)
    @browser.start
  end
  
  config.after(:each) do
#    Spec::Ui::ScreenshotFormatter.instance.take_screenshot_of(@browser)
  end

  config.after(:all) do
    @browser.kill! rescue nil
  end
end
  
