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
       Rake::Task["nedss:dev:load_codes_and_defaults"].invoke
       Rake::Task["db:test:prepare"].invoke
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
      update_locale_config("nedss_development")
    end
    
    desc "update test locale config"
    task :update_test_locale_config do
      update_locale_config("nedss_test")
    end
    
    def update_locale_config(env)
      sh "psql #{env} -c \"UPDATE pg_ts_cfg SET LOCALE = current_setting('lc_collate') WHERE ts_name = 'default'\""
    end

    desc "Load codes and defauts into database"
    task :load_codes_and_defaults => [:load_codes, :load_defaults] do
    end

    desc "Load codes and defauts into database"
    task :load_codes_and_defaults_test => [:load_codes_test, :load_defaults_test] do
    end

    desc "Load codes into database"
    task :load_codes do
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_codes.rb"
    end

    desc "Load defaults into database"
    task :load_defaults do
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_defaults.rb"
    end

  end
  
end
