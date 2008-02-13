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
       ruby "-S rake db:migrate"
       ruby "-S rake db:test:prepare"
       ruby "-S rake spec:db:fixtures:load"
    end
    
  end
  
end
