# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

# You don't need to tweak the $LOAD_PATH if you have RSpec and Spec::Ui installed as gems
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../../rspec/lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../../lib')
$load_time = ENV['NEDSS_PAGE_LOAD'] ||= '30000'

require 'rubygems'
require 'spec'
require File.dirname(__FILE__) + '/selenium'
require File.dirname(__FILE__) + '/nedss_helper'

Spec::Runner.configure do |config|
  include NedssHelper
  
  nedss_url = ENV['TRISANO_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
  nedss_url = nedss_url.sub("//", "//utah:arches@")
    
  config.before(:all) do
    @browser = Selenium::SeleniumDriver.new("localhost", 4444, "*firefox", nedss_url, 10000)
    @browser.start
  end
  
  config.after(:each) do

  end

  config.after(:all) do
    @browser.stop unless $dont_kill_browser #in your test, if you don't want the browser to get killed
                                            #set this variable to true
  end
  
  def wait_for_element_present(name, browser=nil)
    browser = @browser.nil? ? browser : @browser
    !60.times{ break if (browser.is_element_present(name) rescue false); sleep 1 }    
  end
  
  def wait_for_element_not_present(name, browser=nil)
    browser = @browser.nil? ? browser : @browser
    !60.times{ break unless (browser.is_element_present(name) rescue true); sleep 1 }
  end
end
  
