# Copyright (C) 2007, 2008, The Collaborative Software Foundation
#
# This file is part of TriSano.
#
# TriSano is free software: you can redistribute it and/or modify it under the 
# terms of the GNU Affero General Public License as published by the 
# Free Software Foundation, either version 3 of the License, 
# or (at your option) any later version.
#
# TriSano is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License 
# along with TriSano. If not, see http://www.gnu.org/licenses/agpl-3.0.txt.

require 'ftools'
require 'fileutils'
require 'yaml'
require 'sparrowhawk'
require 'tasks/helpers'

namespace :tomcat do
  desc 'Start tomcat instance'
  task :start => 'trisano:tomcat:start'

  desc "Stop tomcat instance"
  task :stop => 'trisano:tomcat:stop'
end

namespace :distro do
  namespace :db do
    desc "Drop, restore, and migrate data dump"
    task :upgrade => 'trisano:distro:db:upgrade'
  end

  desc 'Create and deploy war'
  task :deploy => 'trisano:distro:deploy'

  desc "Create a tar for distribution"
  task :tar => 'trisano:distro:tar'

  desc "Create a war distribution"
  task :war => 'trisano:distro:war'

  namespace :test do
    desc "Full release path monty! Restores the db from a dump, migrates it, and then deploys the war to Tomcat"
    task :release => 'trisano:distro:test:release'
  end
end
  
namespace :trisano do
  include Tasks::Helpers::DistributionHelpers

  namespace :tomcat do
    task :start do
      start_tomcat
    end

    task :stop do
      stop_tomcat
    end
  end

  namespace :distro do

    namespace :db do
      ## "Create a database based on the distribution configuration"
      task :create do
        create_db
        load_db_schema
        create_db_user 
        create_db_permissions
      end

      ## "Drop distribution database (and associated entities)"
      task :drop do
        drop_db 
        drop_db_user
      end

      ## "Export the distribution database"
      task :dump do
        dump_db_to_file
      end
 
      ## "Restore database from a dump file and apply currently configured distribution permission"
      task :restore do
        create_db
        load_dump
        create_db_user
        create_db_permissions
      end

      ## "Run migrations against the configured distribution database"
      task :migrate => [:dump] do
        migrate
      end

      task :upgrade => [:drop, :restore, :migrate, :set_default_admin]
      
      ## "Sometimes we do this to make sure we can get into a application instance
      task :set_default_admin do
        set_default_admin
      end

      ## "Create a database schema based on the current plugin configuration"
      task :schema do
        ruby "-S rake db:release:reset RAILS_ENV=development"
        #TODO: Do this in a throw away database and then throw it away
        dump_db_to_file 'database/trisano_schema.sql'
      end

      namespace :schema do
        ## "Create a database schema with demo data based on the current plugin configuration"
        task :demo do
          ruby "-S db:reset RAILS_ENV=development"
          dump_db_to_file 'database/trisano_schema.sql'
        end
      end
    end

    task :overwrite_footer_urls => :overwrite_urls

    ## "Overwrites hardcoded TriSano URLs with what is in the config.yml *_url attributes"
    task :overwrite_urls do
      overwrite_urls
    end

    task :war => [:overwrite_urls] do
      create_war
    end

    namespace :war do
      task :deploy do
       Rake::Task['distro:war'].invoke unless distro_war_exists?
       deploy_war
      end

      task :undeploy do
        undeploy_war
      end
    end
 
    task :deploy => ['tomcat:stop', 'trisano:distro:war:undeploy', 'trisano:distro:war:deploy', 'trisano:tomcat:start']

    task :tar do
      puts "!!WARNING!!: using following TRISANO_REPO_ROOT #{repo_root}. Please ensure it is correct."
      ruby "-S rake trisano:distro:db:schema"
      ruby "-S rake trisano:distro:war"
      create_tar
    end

    namespace :tar do
      ## "Create a tar with demo data for distribution"
      task :demo do
        puts "!!WARNING!!: using following TRISANO_REPO_ROOT #{repo_root}. Please ensure it is correct."
        puts "==================== This release will include test/demo data. ===================="
        puts "==================== It is not intended to be used for a clean system install ====="
        ruby "-S rake trisano:distro:db:schema:demo"
        create_tar_without_war
      end
    end
 
    namespace :test do
      task :release => ['tomcat:stop', 'trisano:distro:db:upgrade', 'trisano:distro:deploy', 'trisano:distro:smoke']
    end

    ## "smoke test that ensures trisano was deployed"
    task :smoke do
      
      require 'mechanize'
      retries = 5
      url = ENV['TRISANO_URL'] || 'http://localhost:8080/trisano'
      begin
        sleep 10

        agent = WWW::Mechanize.new
        agent.read_timeout = 300

        puts "GET / to #{url}"
        page = agent.get(url)

        raise "GET content invalid" unless (page.search("#errorExplanation")).empty?

        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end
  end
end
