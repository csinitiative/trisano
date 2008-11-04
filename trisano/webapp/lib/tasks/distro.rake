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

require 'fileutils'
require 'logger'
require 'yaml'

namespace :trisano do
  
  namespace :distro do
    WEB_APP_CONFIG_DIR = '../webapp/config/'

    def initialize_config
      config = YAML::load_file "./config.yml"
      @host = config['host'] unless validate_config_attribute(config, 'host')
      @port = config['port'] unless validate_config_attribute(config, 'port')
      @database = config['database'] unless validate_config_attribute(config, 'database')
      postgres_dir = config['postgres_dir'] unless validate_config_attribute(config, 'postgres_dir')
      @psql = postgres_dir + "/psql" 
      @pgdump = postgres_dir + "/pg_dump"
      @priv_uname = config['priv_uname'] unless validate_config_attribute(config, 'priv_uname')
      @priv_password = config['priv_passwd'] unless validate_config_attribute(config, 'priv_passwd')
      @trisano_user = config['trisano_uname'] unless validate_config_attribute(config, 'trisano_uname')
      @trisano_user_pwd = config['trisano_user_passwd'] unless validate_config_attribute(config, 'trisano_user_passwd')
      @environment = config['environment'] unless validate_config_attribute(config, 'environment')
      @basicauth = config['basicauth'] unless validate_config_attribute(config, 'basicauth')
      @min_runtimes = config['min_runtimes'] unless validate_config_attribute(config, 'min_runtimes')
      @max_runtimes = config['max_runtimes'] unless validate_config_attribute(config, 'max_runtimes')
      @dump_file = config['dump_file_name'] 
      ENV["PGPASSWORD"] = @priv_password 
    end

    def validate_config_attribute(config, attribute)
      if config[attribute].nil?
        raise "attribute #{attribute} is not specified in config.yml - please add it and try again."
      end
    end
    
    # Both the creation of the .war file and running of migrations require 
    # database.yml to have the proper settings for the target database.
    # To simplify things we just reset it every time based on the contents
    # of config.yml
    def replace_database_yml(environment, host, port, database, nedss_user, nedss_user_pwd)
      puts "creating database.yml based on contents of config.yml in #{WEB_APP_CONFIG_DIR}"
      db_config = { environment => 
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

    desc "Sets the database.yml to use the priveledged user info"
    task :set_priv_database_yml do
      initialize_config
      replace_database_yml(@environment, @host, @port, @database, @priv_uname, @priv_password)            
    end
    
    desc "Create the database, the user, and apply security permissions"
    task :create_db_dbuser_permissions => [:create_db, :create_db_user, :create_db_permissions] do
      initialize_config
    end

    desc "Create the database"
    task :create_db do
      puts "Creating TriSano database ..."
      initialize_config
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c \"CREATE DATABASE #{@database} ENCODING='UTF8'\"")

      unless success
        puts "Failed creating database structure for TriSano."
        return success
      end
      puts "Creating TriSano database structure ..."
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f ./database/trisano_schema.sql")
      unless success
        puts "Failed creating database structure for TriSano."
        return sucess
      end
      puts "Setting locale for full text search."
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -c \"UPDATE pg_ts_cfg SET LOCALE = current_setting('lc_collate') WHERE ts_name = 'default'\"")
      unless success
        puts "Failed setting locale for full text search."
        return sucess
      end
    end

    desc "Create database user"
    task :create_db_user do
      puts "Creating TriSano user."
      initialize_config
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c \"CREATE USER #{@trisano_user} ENCRYPTED PASSWORD '#{@trisano_user_pwd}'\"")
      unless success
        puts "Failed creating TriSano user." 
        return sucess
      end
    end

    desc "Create database permissions for database user"
    task :create_db_permissions do
      puts "Granting privileges to TriSano user."
      initialize_config
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c 'GRANT ALL ON SCHEMA public TO #{@trisano_user}'")
      unless success
        puts "Granting of privileges to TriSano user failed. Could not install plpgsql language into database."
        return success
      end
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f ./database/load_grant_function.sql")
      unless success
        puts "Granting of privileges to TriSano user failed.  Could not create grant privileges function."
        return success
      end
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -c \"SELECT pg_grant('#{@trisano_user}', 'all', '%', 'public')\"")
      unless success
        puts "Failed granting privileges to TriSano user."
        return sucess
      end
    end

    desc "Drop the database"
    task :drop_db do
      initialize_config
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'drop database #{@database}'")
      unless success
        puts "Failed dropping database: #{database}"
        return sucess
      end
    end

    desc "Drop the database user"
    task :drop_db_user do
      initialize_config
      success = sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'drop user #{@trisano_user}'")
      unless success
        puts "Failed dropping database user: #{@trisano_user}"
        return sucess
      end
    end
    
    desc "Drop the database"
    task :drop_db_and_user => [:drop_db, :drop_db_user] do
    end

    desc "Export the database"
    task :dump_db do
      initialize_config
      dirname = './dump'
      if !File.directory? dirname
        puts "adding directory #{dirname}"
        FileUtils.mkdir(dirname)
      end            
      t = Time.now
      filename = "#{@database}-#{t.strftime("%m-%d-%Y-%I%M%p")}.dump"
      sh "#{@pgdump} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c > #{dirname}/#{filename}"
    end

    desc "Import the database from configured backup file"
    task :restore_db do
      initialize_config
      if @dump_file.nil?
        raise "attribute dump_file_name is not specified in config.yml - please add it and try again."
      end
      dirname = './dump'
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'CREATE DATABASE #{@database}'")
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} < #{dirname}/#{@dump_file}")
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c \"UPDATE pg_ts_cfg SET LOCALE = current_setting('lc_collate') WHERE ts_name = 'default'\"")
    end
    
    desc "Package the application with the settings from config.yml"
    task :package_app do
      initialize_config
      replace_database_yml(@environment, @host, @port, @database, @trisano_user, @trisano_user_pwd)                
      puts "creating .war deployment archive"
      cd '../webapp/'
      ruby "-S rake trisano:deploy:buildwar RAILS_ENV=#{@environment} basicauth=#{@basicauth} min_runtimes=#{@min_runtimes} max_runtimes=#{@max_runtimes}"
      FileUtils.mv('trisano.war', '../distro')
    end

    desc "Migrate the database"
    task :upgrade_db => ['dump_db'] do
      initialize_config   
      replace_database_yml(@environment, @host, @port, @database, @priv_uname, @priv_password)            
      cd '../webapp/'
      ruby "-S rake db:migrate RAILS_ENV=production"
    end

    desc "Set new db permissions"
    task :set_new_db_permissions do      
      initialize_config 
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c 'grant all privileges on table diseases_forms to #{@trisano_user}'")
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c 'grant all privileges on table event_queues to #{@trisano_user}'")
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c 'grant all privileges on table event_queues_id_seq to #{@trisano_user}'")             
    end
  end

end
