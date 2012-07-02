# Copyright (C) 2007, 2008, 2009, 2010, 2011 The Collaborative Software Foundation
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

Webrat.configure do |config|
  config.mode = :selenium
  # Selenium defaults to using the selenium environment. Use the following to override this.
  # config.application_environment = :test
end

require 'database_cleaner'

# Adding our patched-in do-nothing strategy to the list of available strategies.
#
# See lib/database_cleaner/active_record/nothing.rb
#
# Getting around this: http://github.com/aslakhellesoy/cucumber-rails/issues/issue/9
DatabaseCleaner::ActiveRecord.class_eval do
  def self.available_strategies
    %w[truncation transaction nothing]
  end
end

DatabaseCleaner.strategy = :nothing
Cucumber::Rails::World.use_transactional_fixtures = false

require 'spec/expectations'
require 'selenium'

# "before all"
browser = Selenium::SeleniumDriver.new("localhost", 4444, "*chrome /opt/firefox/firefox-bin", "http://localhost:8080", 15000)

Before do
  @browser = browser
  @browser.start
  @browser.open "/trisano/events"
end

After do
  @browser.stop
end

# "after all"
at_exit do
  browser.close rescue nil
end

def browser_eval_script(script)
  script = %Q{ selenium.browserbot.getCurrentWindow().#{script.strip} }
  @browser.get_eval(script)
end
