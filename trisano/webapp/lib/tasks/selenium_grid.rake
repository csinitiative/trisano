require 'rake'
require 'rubygems'

namespace :trisano do

  namespace :selenium do
      
    # Selenium Grid requires MRI rather than JRuby as JRuby won't spawn processes

    SELENIUM_GRID_HOME = ENV['SELENIUM_GRID_HOME'] ||= '/opt/selenium-grid-1.0'
   
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
      runner = MultiProcessSpecRunner.new(6)
      runner.run(Dir['./spec/uat/*_selspec.rb'])
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
