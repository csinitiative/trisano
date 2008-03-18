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
#      ruby "-S rake db:drop RAILS_ENV=test"
#      ruby "-S rake db:create RAILS_ENV=test"
#      ruby "-S rake db:migrate RAILS_ENV=test"
      ruby "-S rake spec:db:fixtures:load RAILS_ENV=test"
      ruby 'stories/integration/all.rb'
    end
    
  end
  
end
