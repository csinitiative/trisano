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

require 'rake'
require 'rubygems'

namespace :trisano do

  namespace :selenium do
      
    # Selenium Grid requires MRI rather than JRuby as JRuby won't spawn processes

    SELENIUM_GRID_HOME = ENV['SELENIUM_GRID_HOME'] ||= '/opt/selenium-grid-1.0'
    SPEC_RUNNER_COUNT = ENV['SPEC_RUNNER_COUNT'] ||= '2'
    SPECS_PATTERN = ENV['SPECS_PATTERN'] ||= './spec/uat/*_selspec.rb'
    REPORTS_PREFIX = ENV['REPORTS_PREFIX'] ||= 'Default'
      
    desc "start selenium grid"
    task :startgrid do     
      sh "./script/start_selenium_grid.sh &"
    end

    desc "stop selenium grid"
    task :stopgrid do      
      sh "./script/stop_selenium_grid.sh &"
    end

    desc "Run all and then display results"
    task :runresults do
      Rake::Task["trisano:selenium:run"].invoke
      Rake::Task["trisano:selenium:results"].invoke
    end

    desc "Run all behaviors in parallel spawing multiple processes"
    task :run => [:report_dir] do
      require './lib/selenium_grid/multi_process_behaviour_runner'
      require './lib/selenium_grid/screenshot_formatter'
      runner = MultiProcessSpecRunner.new(SPEC_RUNNER_COUNT.to_i)
      puts "runnings following specs: #{SPECS_PATTERN}"
      runner.run(Dir[SPECS_PATTERN])
      puts "[complete]"
    end

    desc "TriSano specific - Run all behaviors in parallel spawing multiple processes"
    task :runtrisano => [:report_dir] do
      require './lib/selenium_grid/trisano_multi_process_behaviour_runner'
      require './lib/selenium_grid/screenshot_formatter'
      runner = TriSanoMultiProcessSpecRunner.new(SPEC_RUNNER_COUNT.to_i, REPORTS_PREFIX)
      puts "REPORTS_PREFIX: #{REPORTS_PREFIX}"
      puts "running following specs: #{SPECS_PATTERN}"
      begin
      runner.run(Dir[SPECS_PATTERN])
      puts "[complete]"
    end

    desc "display grid hub console"
    task :console do
      sh "firefox http://localhost:4444/console"
    end

    desc "display grid run results"
    task :results do
      sh "firefox ./selenium_reports/Aggregated-Selenium-Report.html"
    end

    desc "resets the selenium reports dir"
    task :report_dir do
      mkdir_p "./selenium_reports"
      rm_f "./selenium_reports/*.html"
    end

    desc "displays the active grid processes"
    task :ps do
      sh "ps -aef | grep thoughtworks"
    end

    desc "tail the selenium hub log"
    task :hublog do
      sh "tail -f #{SELENIUM_GRID_HOME}/log/hub.log"
    end
    
  end
  
end
