require 'ftools'
require 'fileutils'
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'

namespace :nedss do

  namespace :deploy do
    WAR_FILE_NAME = 'nedss.war'
    # Override with env variable if you have a different Tomcat home - just export it
    TOMCAT_HOME = ENV['TOMCAT_HOME'].nil? ? '/opt/tomcat/apache-tomcat-6.0.14' : ENV['TOMCAT_HOME']
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'
    TOMCAT_DEPLOYED_EXPLODED_WAR_DIR = TOMCAT_DEPLOY_DIR_NAME + '/' + 'nedss'
    TOMCAT_DEPLOYED_WAR_NAME = TOMCAT_DEPLOY_DIR_NAME + '/' + WAR_FILE_NAME

    desc "delete nedss war file and exploded directory from Tomcat"
    task :deletewar do
      puts "attempting to delete war file from Tomcat"
      if File.file? TOMCAT_DEPLOYED_WAR_NAME
        File.delete(TOMCAT_DEPLOYED_WAR_NAME) 
        puts "deleted deployed war file"
      else
        puts "war file not found - did not delete"
      end

      puts "attempting to delete deployed exploded war directory"
      if File.directory? TOMCAT_DEPLOYED_EXPLODED_WAR_DIR 
        FileUtils.remove_dir(TOMCAT_DEPLOYED_EXPLODED_WAR_DIR)
        puts "deleted deployed exploded war directory"
      else
        puts "deployed exploded war directory not found - did not delete"
      end
    end

    desc "copy nedss war file to Tomcat"
    task :copywar do
      puts "attempting to copy war file to Tomcat"
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

    desc "check to see if Tomcat is running"
    task :istomcatup do
      #TODO could check port just do a get?
      puts "not yet implemented"
    end

    desc "stop Tomcat"
    task :stoptomcat do
      puts "attempting to stop Tomcat"
      sh TOMCAT_BIN + "/shutdown.sh"
    end

    desc "start Tomcat"
    task :starttomcat do
      puts "attempting to start Tomcat"
      sh TOMCAT_BIN + "/startup.sh"
    end

    desc "Wait 10 seconds for Tomcat to stop"
    task :waitfortomcattostop do
      puts "waiting for Tomcat to stop"
      sleep 10
    end

    desc "redeploy Tomcat"
    task :redeploytomcat => [:stoptomcat, :waitfortomcattostop, :deletewar, :copywar, :starttomcat] do
      puts "redeploying Tomcat"
    end

  end

  namespace :smoke do
  
    desc "smoke test that excercises basic NEDSS functionality"
    task :test do 
      puts "hi"

      agent = WWW::Mechanize.new
      page = agent.get 'http://ut-nedss-dev.csinitiative.com/nedss/people'
      page2 = agent.get 'http://www.google.com'
      puts page
      puts page2

    end

  end
end
