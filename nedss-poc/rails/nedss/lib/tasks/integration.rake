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
      ruby 'stories/integration/all.rb'
    end
    
  end
  
end
