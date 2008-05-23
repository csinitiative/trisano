require 'rake'
#require 'spec'
require 'rubygems'
#require 'spec/rake/spectask'

namespace :nedss do

  namespace :selenium do
      
    # Selenium Grid requires MRI rather than JRuby as JRuby won't spawn processes

    SELENIUM_GRID_HOME = ENV['SELENIUM_GRID_HOME'] ||= '/opt/selenium-grid-1.0'
   
    desc "start selenium grid"
    task :startgrid do
     
      sh "./script/startselgrid.sh"
    end

    desc "stop selenium grid"
    task :stopgrid do
      
      sh "./script/stopselgrid.sh"
    end

    desc("Run all behaviors in parallel spawing multiple processes")
    task :run => [:report_dir] do
      require './lib/selenium_grid/multi_process_behaviour_runner'
      require './lib/selenium_grid/screenshot_formatter'
      runner = MultiProcessSpecRunner.new(2)

      runner.run(Dir['/home/mike/projects/ut-nedss/spec/uat/*_selspec.rb'])

    end

    task :report_dir do
      mkdir_p "./selenium_reports"
      rm_f "./selenium_reports/*.html"
    end

    
  end
  
end
