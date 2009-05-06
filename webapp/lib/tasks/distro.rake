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
      config = YAML::load_file "../distro/config.yml"
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
      @runtime_timeout = config['runtime_timeout'] unless validate_config_attribute(config, 'runtime_timeout')
      @dump_file = config['dump_file_name'] 
      @support_url = config['support_url']

      # Data warehouse config options
      @dw_database = config['dw_database'] unless validate_config_attribute(config, 'dw_database')
      @dw_priv_uname = config['dw_priv_uname'] unless validate_config_attribute(config, 'dw_priv_uname')
      @dw_priv_passwd = config['dw_priv_passwd'] unless validate_config_attribute(config, 'dw_priv_passwd')
      @dw_user = config['dw_uname'] unless validate_config_attribute(config, 'dw_uname')
      @dw_user_pwd = config['dw_user_passwd'] unless validate_config_attribute(config, 'dw_user_passwd')
      @source_db_host = config['source_db_host'] unless validate_config_attribute(config, 'source_db_host')
      @source_db_port = config['source_db_port'] unless validate_config_attribute(config, 'source_db_port')
      @source_db_name = config['source_db_name'] unless validate_config_attribute(config, 'source_db_name')
      @source_db_user = config['source_db_user'] unless validate_config_attribute(config, 'source_db_user')
      @dest_db_host = config['dest_db_host'] unless validate_config_attribute(config, 'dest_db_host')
      @dest_db_port = config['dest_db_port'] unless validate_config_attribute(config, 'dest_db_port')
      @dw_tool_install_path = config['dw_tool_install_path'] unless validate_config_attribute(config, 'dw_tool_install_path')

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
          { 'adapter' => 'jdbcpostgresql',
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

    def change_text_in_file(file, regex_to_find, text_to_put_in_place)
      text= File.read file
      File.open(file, 'w+'){|f| f << text.gsub(regex_to_find, text_to_put_in_place)}
    end

    def create_db_user
      puts "Creating TriSano user: #{@trisano_user}."
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c \"CREATE USER #{@trisano_user} ENCRYPTED PASSWORD '#{@trisano_user_pwd}'\"")
      unless success
        puts "Failed creating TriSano user: #{@trisano_user}"
        return success
      end
      puts "Success creating TriSano user: #{@trisano_user}"
      return success
    end

    def create_db_permissions 
      puts "Granting privileges to TriSano user: #{@trisano_user}."
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -c 'GRANT ALL ON SCHEMA public TO #{@trisano_user}'")
      unless success
        puts "Granting of privileges to TriSano user: #{@trisano_user} failed. Could not install plpgsql language into database."
        return success
      end
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f ./database/load_grant_function.sql")
      unless success
        puts "Granting of privileges to TriSano user: #{@trisano_user} failed.  Could not create grant privileges function."
        return success
      end
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -c \"SELECT pg_grant('#{@trisano_user}', 'all', '%', 'public')\"")
      unless success
        puts "Failed granting privileges to TriSano user: #{@trisano_user}."
        return success
      end
      puts "Success granting privileges to TriSano user: #{@trisano_user}."
      return success
    end

    def create_db 
      puts "Creating TriSano database ..."
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c \"CREATE DATABASE #{@database} ENCODING='UTF8'\"")
      unless success
        puts "Failed creating database structure for TriSano."
        return success
      end
      puts "Creating TriSano database structure ..."
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f ./database/trisano_schema.sql")
      unless success
        puts "Failed creating database structure for TriSano."
        return success
      end 
      puts "Success creating database structure for TriSano."
      return success
    end

    def dump_db_to_file(dump_file_name)
      dirname = './dump'
      if !File.directory? dirname
        puts "adding directory #{dirname}"
        FileUtils.mkdir(dirname)
      end            
      # dump sans access privs/acl & sans object owner - we grant auth on restore to make moving dump files between envIRONments easier
      filename = "#{dirname}/#{dump_file_name}"
      puts "#{@pgdump} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -x -O > #{filename}"
      File.open(filename, 'w') {|f| f.write("\\set ON_ERROR_STOP\n\n") }
      success = system("#{@pgdump} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -x -O >> #{filename}")
      puts "Created dump file: #{dirname}/#{dump_file_name}"
      unless success
        puts "Failed to create #{dirname}/#{dump_file_name}"
        return success
      end
      return success
    end

    def run_etl_script
      puts "Running the DW ETL script"
      init_substitution = "sed "
      init_substitution << "-e 's/\$SOURCE_DB_HOST/#{@source_db_host}/g' "
      init_substitution << "-e 's/\$SOURCE_DB_PORT/#{@source_db_port}/g' "
      init_substitution << "-e 's/\$SOURCE_DB_NAME/#{@source_db_name}/g' "
      init_substitution << "-e 's/\$SOURCE_DB_USER/#{@source_db_user}/g' "
      init_substitution << "-e 's/\$DEST_DB_HOST/#{@dest_db_host}/g' "
      init_substitution << "-e 's/\$DEST_DB_PORT/#{@dest_db_port}/g' "
      init_substitution << "-e 's/\$DEST_DB_NAME/#{@dw_database}/g' "
      init_substitution << "-e 's/\$DEST_DB_USER/#{@dw_priv_uname}/g' "
      init_substitution << "-e 's:\$PGSQL_PATH:#{@psql[0...@psql.size-5]}:g' "
      init_substitution << "-e 's:\$ETL_SCRIPT:../bi/scripts/dw.sql:g'"
      raise "failed to substitute etl configuration" unless system("#{init_substitution} <../bi/scripts/etl.sh >../bi/scripts/etl_to_run.sh")
      raise "failed to chmod etl script" unless system("chmod 755 ../bi/scripts/etl_to_run.sh")
      raise "failed to run etl script" unless system("../bi/scripts/etl_to_run.sh")
      raise "failed to remove etl script" unless system("rm ../bi/scripts/etl_to_run.sh")
    end

    desc "Sets the database.yml to use the privileged user info"
    task :set_priv_database_yml do
      initialize_config
      replace_database_yml(@environment, @host, @port, @database, @priv_uname, @priv_password)            
    end

    desc "Sets the database.yml to use the application user info"
    task :set_trisano_database_yml do
      initialize_config
      replace_database_yml(@environment, @host, @port, @database, @trisano_user, @trisano_user_pwd)            
    end
    
    desc "Create the database, the user, and apply security permissions"
    task :create_db_dbuser_permissions  do
      initialize_config      
      if ! create_db
        raise "failed to create database"
      end
      if ! create_db_user
        raise "failed to create user"
      end
      if ! create_db_permissions
        raise "failed to set db permissions"
      end
      puts "Success creating TriSano db: #{@database}"
    end

    desc "Drop the database"
    task :drop_db do
      initialize_config
      
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'drop database #{@database}'") do |ok, res|
        if ! ok
          puts "Failed dropping database: #{@database} with error #{res.exitstatus}"
        end
      end
    end

    desc "Drop the database user"
    task :drop_db_user do
      initialize_config

      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'drop user #{@trisano_user}'") do |ok, res|
        if ! ok
          puts "Failed dropping database user: #{@trisano_user} with error #{res.exitstatus}"
        end
      end
    end
    
    desc "Drop the database"
    task :drop_db_and_user => [:drop_db, :drop_db_user] do
    end

    desc "Export the database"
    task :dump_db do
      initialize_config
      t = Time.now
      filename = "#{@database}-#{t.strftime("%m-%d-%Y-%I%M%p")}.dump"
      dump_db_to_file(filename)
    end

    desc "Import the database from configured backup file, create user (if needed), and set permissions"
    task :restore_db do
      initialize_config
      if @dump_file.nil?
        raise "attribute dump_file_name is not specified in config.yml - please add it and try again."
      end
      dirname = './dump'
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} postgres -e -c 'CREATE DATABASE #{@database}'") do |ok, res|
        if ! ok
          raise "Failed creating database: #{@database} with error #{res.exitstatus}. Try running drop_db_and_user.rb."
        end
      end
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} < #{dirname}/#{@dump_file}") do |ok, res|
        if ! ok
          raise "Failed importing dumpfile: #{@dump_file} into database #{@database} with error #{res.exitstatus}"
        end
      end
      if ! create_db_user
        puts "assuming already exists and continuing ..."
      end
      if ! create_db_permissions
        raise "failed to set db permissions"
      end
      puts "Success restoring TriSano db: #{@database} from #{dirname}/#{@dump_file}"     
    end

    desc "Overwrites the TriSano Support URL with what is in the config.yml support_url attribute"
    task :overwrite_support_url do
      puts "starting overwrite"
      initialize_config
      if ! @support_url.nil?
        puts "overwriting TriSano Support URL with #{@support_url}"
        change_text_in_file('../webapp/app/views/layouts/application.html.haml', "http://www.trisano.org/collaborate/", @support_url) 
      end
    end
    
    desc "Package the application with the settings from config.yml"
    task :package_app => [:overwrite_support_url] do
      initialize_config
      replace_database_yml(@environment, @host, @port, @database, @trisano_user, @trisano_user_pwd)                
      puts "creating .war deployment archive"
      cd '../webapp/'
      ruby "-S rake trisano:deploy:buildwar RAILS_ENV=#{@environment} basicauth=#{@basicauth} min_runtimes=#{@min_runtimes} max_runtimes=#{@max_runtimes} runtime_timeout=#{@runtime_timeout}"
      FileUtils.mv('trisano.war', '../distro')
      puts "Success packaging trisano.war"
    end

    desc "Migrate the database"
    task :upgrade_db => ['dump_db'] do
      initialize_config   
      replace_database_yml(@environment, @host, @port, @database, @priv_uname, @priv_password)            
      cd '../webapp/'
      ruby "-S rake db:migrate RAILS_ENV=production"
      puts "resetting db permissions"
      cd '../distro/'
      if ! create_db_permissions
        raise "failed to set db permissions"
      end
    end

    desc "Reset FTS in 8.3"
    task :reset_fts do
      initialize_config
      puts "resetting fts in postgres 8.3"
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -c 'CREATE LANGUAGE plpgsql'") do |ok, res|
        if ! ok
          puts "Failed to create language plpgsql #{res.exitstatus}"
          puts "No-op, language probably already exists. If not, the next execution will fail"
        end
      end
      puts "creating people index function and trigger"
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f ./database/create_people_fts_trigger.sql")
      unless success
        puts "Failed to create people fts function and trigger"
        return success
      end
    end

    desc "Install the data warehouse"
    task :install_data_warehouse do
      initialize_config
      puts "Installing the data warehouse"

      raise "failed to create data warehouse database" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} postgres -e -c \"CREATE DATABASE #{@dw_database} ENCODING='UTF8'\"")      
      raise "failed to set public schema ownership" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} #{@dw_database} -c 'ALTER SCHEMA public OWNER TO #{@dw_priv_uname};'")
      raise "failed to create data warehouse user" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} #{@dw_database} -c \"CREATE USER #{@dw_user} ENCRYPTED PASSWORD '#{@dw_user_pwd}'\"")
      raise "failed to set search path" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} #{@dw_database} -c 'ALTER USER #{@dw_user} SET search_path = trisano;'")
      raise "failed to substitute warehouse init configuration" unless system("sed -e 's/trisano_su/#{@dw_priv_uname}/g' -e 's/trisano_ro/#{@dw_user}/g' <../bi/scripts/warehouse_init.sql >../bi/scripts/warehouse_init_to_run.sql")
      raise "failed to run warehouse init script" unless system("#{@psql} -X -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} #{@dw_database} -f ../bi/scripts/warehouse_init_to_run.sql")
      raise "failed to remove warehouse init script" unless system("rm ../bi/scripts/warehouse_init_to_run.sql")

      run_etl_script

      raise "failed to create Pentaho repository" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} -f #{@dw_tool_install_path}/biserver-ce/data/postgresql/create_repository_postgresql.sql")
      raise "failed to create Quartz database" unless system("#{@psql} -U #{@dw_priv_uname} -h #{@dest_db_host} -p #{@dest_db_port} -f #{@dw_tool_install_path}/biserver-ce/data/postgresql/create_quartz_postgresql.sql")
    end

    desc "Run the data warehouse etl script"
    task :run_data_warehouse_etl do
      initialize_config
      run_etl_script
    end

  end
end
