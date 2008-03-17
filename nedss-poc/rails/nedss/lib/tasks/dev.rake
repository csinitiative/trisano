# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

namespace :nedss do

  namespace :dev do
       
    # You can invoke a Rake task with Rake::Task["db:create:all"].invoke, but the fixture loading
    # step below fails. Dig into that at some point.
    desc "full rebuild of all databases"
    task :db_rebuild_full do
      puts "doing full rebuild of all databases"
       ruby "-S rake db:drop:all"
       ruby "-S rake db:create:all"
       ruby "-S rake db:migrate"
       ruby "-S rake spec:db:fixtures:load"
    end
    
    desc "full rebuild of all databases for the build server"
    task :db_rebuild_full_for_build  => ['nedss:deploy:stoptomcat', 'db_rebuild_full'] do
    end
    
    # Debt: DRY up the tsearch tasks. They could be a bit more dynamic
    
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
    
    # The locale tasks that follow probably could be dried up a bit more, as well

    desc "update locale configs"
    task :update_locale_configs => [:update_dev_locale_config, :update_test_locale_config] do
    end
    
    desc "update dev locale config"
    task :update_dev_locale_config do
      update_locale_config("development")
    end
    
    desc "update test locale config"
    task :update_test_locale_config do
      update_locale_config("test")
    end
    
    def update_locale_config(env)
      config = ActiveRecord::Base.configurations[env]
      ActiveRecord::Base.establish_connection(config)  
      ActiveRecord::Base.connection.execute("update pg_ts_cfg set locale = '#{PG_LOCALE}' where ts_name = 'default';")
    end
    
  end
  
end
