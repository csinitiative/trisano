require 'fileutils'
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'
require 'logger'
require 'yaml'

namespace :trisano do
  
  namespace :distro do
    WAR_FILE_NAME = 'nedss.war'
    # Override with env variable if you have a different Tomcat home - just export it
    TOMCAT_HOME = ENV['TOMCAT_HOME'] ||= '/opt/tomcat/apache-tomcat-6.0.14' 
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'
    TOMCAT_DEPLOYED_EXPLODED_WAR_DIR = TOMCAT_DEPLOY_DIR_NAME + '/' + 'nedss'
    TOMCAT_DEPLOYED_WAR_NAME = TOMCAT_DEPLOY_DIR_NAME + '/' + WAR_FILE_NAME
    # Override with env variable if you are running locally http://localhost:8080
    NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
    RELEASE_DIRECTORY = './release'
    NEDSS_PROD_DIR = 'script/production'
    GEM_DIR = '/home/mike/gems'

    desc "Stop the web application"
    task :stop_app do

    end

    desc "Start the web application"
    task :start_app do

    end

    desc "Export the database"
    task :dump_db do
      dirname = './dump'
      if !File.directory? './dump'
        puts "adding directory #{dirname}"
        FileUtils.mkdir(dirname)
      end      
      
      config = YAML::load_file "../distro/config.yml"
      database = config['database']
      sh "pg_dump -c -O -c #{database} > #{dirname}/#{database}-dump.sql"
    end

    desc "Package the application with the settings from config.yml"
    task :package_app do

    end

    desc "Migrate the database up"
    task :upgrade_db do

    end

    desc "Migrate the database down."
    task :downgrade_db do

    end

    desc "Deploy the web application"
    task :deploy_app do

    end


  end

end
