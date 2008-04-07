# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :nedss do

  namespace :integration do
         
    desc "run integration tests"
    task :run_all do
      puts "Running all integration test stories"
      
      # Because of some strange error, this task has to be run after a successful spec run
      # and the following doesn't work yet

      Rake::Task["db:test:prepare"].invoke
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_codes.rb"
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_defaults.rb"
      ruby 'stories/integration/all.rb'
    end
    
  end
  
end
