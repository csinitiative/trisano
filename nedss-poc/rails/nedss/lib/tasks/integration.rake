# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :nedss do

  namespace :integration do
    
    # Override with env variable if you are running locally http://localhost:8080
    NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'\
      
    desc "run integration tests"
    task :run_all do
      puts "Running all integration test stories"
      ruby 'stories/integration/all.rb'
    end
    
  end
  
end
