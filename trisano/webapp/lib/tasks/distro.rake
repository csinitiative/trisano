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
    WEB_APP_DIR = './WEB-INF/config'

    desc "Export the database"
    task :dump_db do
      dirname = './dump'
      if !File.directory? dirname
        puts "adding directory #{dirname}"
        FileUtils.mkdir(dirname)
      end      
      
      config = YAML::load_file "./config.yml"
      database = config['database']
      sh "pg_dump -c -O -c #{database} > #{dirname}/#{database}-dump.sql"
    end

    desc "Package the application with the settings from config.yml"
    task :package_app do
      #TODO this could be simplified, but I wanted to make use of an old script that was working rather than redo now.
      config = YAML::load_file "./config.yml"
    
      host = config['host']
      port = config['port']
      database = config['database']
      nedss_user = config['nedss_uname']
      nedss_user_pwd = config['nedss_user_passwd']
      
      puts "adding directory tree #{WEB_APP_DIR}"
      FileUtils.mkdir_p(WEB_APP_DIR)      
      
      puts "creating web.xml"
  
      db_config = { 'production' => 
          { 'adapter' => 'postgresql', 
          'encoding' => 'unicode', 
          'database' => database, 
          'username' => nedss_user, 
          'password' => nedss_user_pwd,
          'host' => host, 
          'port' => port
        }      
      }
  
      File.open(WEB_APP_DIR + "/database.yml", "w") {|file| file.puts(db_config.to_yaml) }              
      
      puts "creating .war deployment archive"
      cd '../webapp/'
      ruby "-S rake nedss:deploy:buildwar RAILS_ENV=production basicauth=false"
      FileUtils.mv('nedss.war', '../distro')
      
      cd '../distro'
      puts "adding database.yml to nedss.war"
      system("jar uf nedss.war #{WEB_APP_DIR}/database.yml")
    end

    desc "Migrate the database up"
    task :upgrade_db do
      cd '../webapp/'
      ruby "-S rake db:migrate RAILS_ENV=production"
    end

    desc "Migrate the database down."
    task :downgrade_db do
     # could take variable past in and set VERSION?
     # could squirell away the previous VERSION# in a .txt file or something?
    end

    desc "Deploy the web application"
    task :deploy_app do
      puts "not yet implemented"
    end
    
    desc "Stop the web application"
    task :stop_app do
      puts "not yet implemented"
    end

    desc "Start the web application"
    task :start_app do
      puts "not yet implemented"
    end    


  end

end
