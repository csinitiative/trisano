require 'ftools'

namespace :nedss do

  namespace :deploy do
    WAR_FILE_NAME = 'nedss.war'
    TOMCAT_DEPLOY_DIR_NAME = '/opt/tomcat/apache-tomcat-6.0.14/webapps'

    desc "deploy nedss to Tomcat"
    task :tomcat do
      puts "attempting to deploy to Tomcat"
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
  end
end

  

