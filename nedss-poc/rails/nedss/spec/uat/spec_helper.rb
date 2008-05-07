# You don't need to tweak the $LOAD_PATH if you have RSpec and Spec::Ui installed as gems
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../../rspec/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../lib')

require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/selenium'

Spec::Runner.configure do |config|
  
  nedss_url = ENV['NEDSS_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
  nedss_url = nedss_url.sub("//", "//utah:arches@")
  #nedss_url += "/nedss/cmrs"
  
  config.before(:all) do
    @browser = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", nedss_url, 10000)
    @browser.start
  end
  
  config.after(:each) do

  end

  config.after(:all) do
    @browser.stop unless $browser
  end
end
  
