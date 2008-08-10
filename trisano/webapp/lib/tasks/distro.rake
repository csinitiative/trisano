require 'fileutils'
require 'logger'
require 'yaml'

namespace :trisano do
  
  namespace :distro do
    WEB_APP_CONFIG_DIR = '../webapp/config/'

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
    
    # Both the creationg of the .war file and running of migrations require 
    # database.yml to have the proper settings for the target database.
    # To simplify things we just reset it every time based on the contents
    # of config.yml
    def replace_database_yml
      config = YAML::load_file "./config.yml"
      
      host = config['host']
      port = config['port']
      database = config['database']
      nedss_user = config['nedss_uname']
      nedss_user_pwd = config['nedss_user_passwd']      
      
      puts "creating database.yml based on contents of config.yml in #{WEB_APP_CONFIG_DIR}"
  
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
  
      File.open(WEB_APP_CONFIG_DIR + "/database.yml", "w") {|file| file.puts(db_config.to_yaml) }                    
    end

    desc "Package the application with the settings from config.yml"
    task :package_app do
            
      replace_database_yml
                
      puts "creating .war deployment archive"
      cd '../webapp/'
      ruby "-S rake nedss:deploy:buildwar RAILS_ENV=production basicauth=false"
      FileUtils.mv('nedss.war', '../distro')
    end

    desc "Migrate the database up"
    task :upgrade_db do
      replace_database_yml
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
