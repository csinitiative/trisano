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
gem 'mechanize', "< 0.8.0"
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'
require 'logger'

namespace :trisano do

  # Supported rake task arguments:
  # RAILS_ENV - controls what database config to use
  # basicauth - whether or not to use HTTP Basic Auth from within the .war file (default = true)
  # min - sets the minimum number of Rails instances in the pool (default is 4)
  # max - sets the maximum number of Rails instances in the pool (defaul is 10)
  # Example: jruby -S rake trisano:deploy:buildwar RAILS_ENV=production basicauth=false
  namespace :deploy do
    WAR_FILE_NAME = 'trisano.war'
    # Override with env variable if you have a different Tomcat home - just export it
    TOMCAT_HOME = ENV['TOMCAT_HOME'] ||= '/opt/tomcat/apache-tomcat-6.0.14'
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'
    TOMCAT_DEPLOYED_EXPLODED_WAR_DIR = TOMCAT_DEPLOY_DIR_NAME + '/' + 'trisano'
    TOMCAT_DEPLOYED_WAR_NAME = TOMCAT_DEPLOY_DIR_NAME + '/' + WAR_FILE_NAME
    # Override with env variable if you are running locally http://localhost:8080
    TRISANO_URL = ENV['TRISANO_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
    TRISANO_SVN_ROOT = ENV['TRISANO_SVN_ROOT'] ||= '~/projects/trisano'
    TRISANO_DIST_DIR = ENV['TRISANO_DIST_DIR'] ||= '~/trisano-dist'

    def core_release_tasks(delete_war = true)
      t = Time.now
      tformated = t.strftime("%m-%d-%Y-%I%M%p")
      filename = "trisano-release-" + t.strftime("%m-%d-%Y-%I%M%p") + ".tar.gz"
      dist_dirname = TRISANO_DIST_DIR + "/" + tformated

      sh "cp -R #{TRISANO_SVN_ROOT} #{dist_dirname}"

      p "removing .git directory"
      sh "rm -rf #{dist_dirname}/.git"

      # tried to get tar --exclude to work, but had no luck - bailing to a simpler approach
      p "removing tmp directories from #{dist_dirname}"
      cd dist_dirname

      trisano_war_file = "trisano.war"
      if File.file? "./webapp/#{trisano_war_file}"
        File.delete("./webapp/#{trisano_war_file}")
        puts "deleted ./webapp/#{trisano_war_file}"
      end
      if File.file? "./distro/#{trisano_war_file}" and delete_war
        File.delete("./distro/#{trisano_war_file}")
        puts "deleted ./distro/#{trisano_war_file}"
      end
      sh "rm ./webapp/log/*.*"
      sh "rm -rf ./webapp/nbproject"
      sh "rm -rf ./distro/dump"
      sh "rm -rf ./webapp/tmp"
      sh "rm -rf ./distro/*.txt"
      sh "rm -rf ./webapp/vendor/plugins/safe_record"
      sh "rm -rf ./webapp/vendor/plugins/safe_erb"

      cd TRISANO_DIST_DIR
      sh "tar czfh #{filename} ./#{tformated}"
    end

    desc "delete trisano war file and exploded directory from Tomcat"
    task :deletewar do
      puts "attempting to delete war file from Tomcat"
      if File.file? TOMCAT_DEPLOYED_WAR_NAME
        File.delete(TOMCAT_DEPLOYED_WAR_NAME)
        puts "deleted deployed war file"
      else
        puts "war file not found - did not delete"
      end

      puts "attempting to delete deployed exploded war directory #{TOMCAT_DEPLOYED_EXPLODED_WAR_DIR}"
      if File.directory? TOMCAT_DEPLOYED_EXPLODED_WAR_DIR
        FileUtils.remove_dir(TOMCAT_DEPLOYED_EXPLODED_WAR_DIR)
        puts "deleted deployed exploded war directory"
      else
        puts "deployed exploded war directory not found - did not delete"
      end
    end

    desc "build war file"
    task :buildwar do
      puts "running warble clean"
      ruby "-S warble war:clean"
      puts "running warble war"
      ruby "-S warble war"
    end

    desc "copy trisano war file to Tomcat"
    task :copywar do
      puts "attempting to copy #{WAR_FILE_NAME} war file to Tomcat #{TOMCAT_DEPLOY_DIR_NAME}"
      if files_exist
        File.copy(WAR_FILE_NAME, TOMCAT_DEPLOY_DIR_NAME, true)
      else
        which_files_exist
      end
    end

    def files_exist
      File.file? WAR_FILE_NAME
      File.directory? TOMCAT_DEPLOY_DIR_NAME
    end

    def which_files_exist
      puts "#{WAR_FILE_NAME} exists? #{File.file? WAR_FILE_NAME} #{TOMCAT_DEPLOY_DIR_NAME} exists? #{File.directory? TOMCAT_DEPLOY_DIR_NAME}"
    end

    desc "stop Tomcat"
    task :stoptomcat do
      puts "attempting to stop Tomcat"
      sh TOMCAT_BIN + "/shutdown.sh"
      sleep 10
    end

    desc "start Tomcat"
    task :starttomcat do
      puts "attempting to start Tomcat"
      sh TOMCAT_BIN + "/startup.sh"
    end

    desc "smoke test that ensures trisano was deployed"
    task :smoke do
      retries = 5
      begin
        sleep 10
        puts "executing smoke test"

        Hpricot.buffer_size = 65536
        #agent = WWW::Mechanize.new {|a| a.log = Logger.new(STDERR) }
        agent = WWW::Mechanize.new
        agent.read_timeout = 300
        #agent.set_proxy("localhost", "8118")

        puts "GET / to #{TRISANO_URL}/trisano/"
        url = TRISANO_URL + '/trisano'
        page = agent.get(url)

        raise "GET content invalid" unless (page.search("//#errorExplanation")).empty?

        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end

    desc "redeploy Tomcat"
    task :redeploytomcat => [:stoptomcat, :deletewar, :copywar, :starttomcat, :smoke] do
      puts "redeploy Tomcat success"
    end

    desc "redeploy Tomcat"
    task :redeploytomcat_no_smoke => [:stoptomcat, :deletewar, :copywar, :starttomcat] do
      puts "redeploy Tomcat success"
    end

    desc "build war and redeploy Tomcat"
    task :buildandredeploy => [:buildwar, :redeploytomcat] do
      puts "build and redeploy success"
    end

    desc "build and redeploy full: alias for build and redeploy"
    task :buildandredeployfull => [:buildandredeploy] do
      puts "build and redeploy"
    end

    desc "Create database configuration file for a production install"
    task :create_db_config do
      ruby "-S rake trisano:dev:release_db_rebuild_full RAILS_ENV=development"
      sh "pg_dump -x -O trisano_development > ../distro/database/trisano_schema.sql"
    end

    desc "Create database configuration file for a test or demo install"
    task :create_demo_db_config do
      ruby "-S rake trisano:dev:db_rebuild_full RAILS_ENV=development"
      sh "pg_dump -x -O trisano_development > ../distro/database/trisano_schema.sql"
    end

    desc "package production .war file, include database dump, scripts, and configuration files in a .tar"
    task :release  do
      puts "!!WARNING!!: using following TRISANO_SVN_ROOT: #{TRISANO_SVN_ROOT}. Please ensure it is correct."
      ruby "-S rake trisano:deploy:create_db_config"
      core_release_tasks
    end

    desc "package production .war file, include database dump, scripts, and configuration files in a .tar"
    task :prod_release  do
      puts "!!WARNING!!: using following TRISANO_SVN_ROOT: #{TRISANO_SVN_ROOT}. Please ensure it is correct."
      ruby "-S rake trisano:deploy:create_db_config"
      ruby "-S rake -f ../webapp/Rakefile trisano:distro:package_app"
      core_release_tasks(false)
    end

    desc "package production .war file with demo/testing data, include database dump, scripts, and configuration files in a .tar"
    task :test_release  do
      puts "!!WARNING!!: using following TRISANO_SVN_ROOT: #{TRISANO_SVN_ROOT}. Please ensure it is correct."
      puts "==================== This release will include test/demo data. ===================="
      puts "==================== It is not intended to be used for a clean system install ====="
      ruby "-S rake trisano:deploy:create_demo_db_config"
      core_release_tasks
    end

  end
end
