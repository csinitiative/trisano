require 'ftools'

namespace :nedss do

  namespace :deploy do
    WAR_FILE_NAME = 'nedss.war'
    TOMCAT_HOME = '/opt/tomcat/apache-tomcat-6.0.14'
    #TOMCAT_HOME = '/home/mike/opt/apache-tomcat-6.0.14'
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'

    desc "delete nedss war file and exploded directory from Tomcat"
    task :deletewar do
      puts "attempting to delete war file from Tomcat"

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
      Dir.chdir(TOMCAT_BIN) 
      sh "./shutdown.sh"
    end

    desc "force stop Tomcat"
    task :forcestoptomcat do

      puts "attempting to force stop Tomcat"
      Dir.chdir(TOMCAT_BIN) 
      sh %{./catalina.sh stop -force}

    end

    desc "start Tomcat"
    task :starttomcat do
      puts "attempting to start Tomcat"
      Dir.chdir(TOMCAT_BIN)
      sh "./startup.sh"
    end

    desc "restart Tomcat"
    task :restarttomcat => [:istomcatup, :stoptomcat, :starttomcat] do
      puts "restart"
    end

    desc "test"
    task :testit do
      puts "test start"
      task(:stoptomcat).invoke
      puts "test stop"
    end

  end
end

  

