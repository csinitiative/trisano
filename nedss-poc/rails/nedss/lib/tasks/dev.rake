# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :nedss do

  namespace :dev do
         
    desc "full rebuild of all databases"
    task :db_rebuild_full do
      puts "doing full rebuild of all databases"
       ruby "-S rake db:drop:all"
       ruby "-S rake db:create:all"
       ruby "-S rake nedss:dev:add_tsearch"
       ruby "-S rake db:migrate"
       ruby "-S rake db:migrate RAILS_ENV='test'"
       # ruby "-S rake db:test:prepare"
       ruby "-S rake spec:db:fixtures:load"
    end
    
    desc "add tsearch functions to dev and test"
    task :add_tsearch => [:add_tsearch_to_dev, :add_tsearch_to_test] do
       puts "tsearch support added to dev and test"
    end
    
    desc "add tsearch functions to dev"
    task :add_tsearch_to_dev do
      puts "adding tsearch to dev"
      sh "psql nedss_development < db/tsearch2.sql"
    end
    
    desc "add tsearch functions to test"
    task :add_tsearch_to_test do
      puts "adding tsearch to test"
      sh "psql nedss_test < db/tsearch2.sql"
    end
    
  end
  
end
