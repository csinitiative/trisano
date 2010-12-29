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
      @source_url = config['source_url']
      @feedback_url = config['feedback_url']
      @feedback_email = config['feedback_email']
      @default_admin_uid = config['default_admin_uid']

      ENV["PGPASSWORD"] = @priv_password 
    end

    def distro_dir
      File.expand_path File.dirname(__FILE__) +  '/../../../distro'
    end

    def binstubs?
      File.directory?('bin')
    end

    def validate_config_attribute(config, attribute)
      if config[attribute].nil?
        raise "attribute #{attribute} is not specified in config.yml - please add it and try again."
      end
    end

    def with_replaced_database_yml(options)
      backup_database_yml
      replace_database_yml(options)
      yield if block_given?
    ensure
      restore_database_yml
    end

    def backup_database_yml
      File.copy(WEB_APP_CONFIG_DIR + "database.yml", WEB_APP_CONFIG_DIR + "database.yml.bak", true)
    end

    def restore_database_yml
      File.move(WEB_APP_CONFIG_DIR + "database.yml.bak", WEB_APP_CONFIG_DIR + "database.yml", true)
    end
    
    # Both the creation of the .war file and running of migrations require 
    # database.yml to have the proper settings for the target database.
    # To simplify things we just reset it every time based on the contents
    # of config.yml
    def replace_database_yml(options)
      puts "creating database.yml based on contents of config.yml in #{WEB_APP_CONFIG_DIR}"
      db_config = { options[:environment] =>
          { 'adapter' => 'postgresql',
          'encoding' => 'unicode', 
          'database' => options[:database],
          'username' => options[:user],
          'password' => options[:password],
          'host' => options[:host],
          'port' => options[:port]
        }      
      }
      File.open(WEB_APP_CONFIG_DIR + "database.yml", "w") {|file| file.puts(db_config.to_yaml) }
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
      success = system("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -f #{distro_dir}/database/load_grant_function.sql")
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
      dirname = "#{distro_dir}/dump"
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

    desc "Sets the database.yml to use the privileged user info"
    task :set_priv_database_yml do
      initialize_config
      replace_database_yml(
        :environment => @environment, 
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @priv_uname,
        :password => @priv_password
      )
    end

    desc "Sets the database.yml to use the application user info"
    task :set_trisano_database_yml do
      initialize_config
      replace_database_yml(
        :environment => @environment,
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @trisano_user,
        :password => @trisano_user_pwd
      )
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
      dirname = "#{distro_dir}/dump"
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

    #desc "Old name for overwrite_urls (Overwrites the hardcoded TriSano URLs)"
    task :overwrite_footer_urls => :overwrite_urls

    desc "Overwrites hardcoded TriSano URLs with what is in the config.yml *_url attributes"
    task :overwrite_urls do
      puts "starting overwrite"
      initialize_config
      if ! @support_url.nil?
        puts "overwriting TriSano Support URL with #{@support_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://www.trisano.org/collaborate/\'", "#{@support_url}\'")
      end
      if ! @feedback_url.nil?
        puts "overwriting TriSano Feedback URL with #{@feedback_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/app/controllers/application_controller.rb', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/public/500.html', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/public/503.html', "http://groups.google.com/group/trisano-user", @feedback_url)
      end
      if ! @feedback_email.nil?
        puts "overwriting TriSano Feedback email with #{@feedback_email}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "trisano-user@googlegroups.com", @feedback_email)
      end
      if ! @source_url.nil?
        puts "overwriting TriSano Source URL with #{@source_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://github.com/csinitiative/trisano/tree/master", @source_url) 
      end
    end

    desc "Package the application with the settings from config.yml"
    task :package_app => [:overwrite_urls] do
      initialize_config
      db_config_options = {
        :environment => @environment,
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @trisano_user,
        :password => @trisano_user_pwd
      }
      with_replaced_database_yml(db_config_options) do
        puts "creating .war deployment archive"
        cd '../webapp/'
        Sparrowhawk::Configuration.new do |config|
          config.other_files = FileList['Rakefile']
          config.application_dirs = %w(app config lib vendor db script)
          config.environment = @environment
          config.runtimes = @min_runtimes.to_i..@max_runtimes.to_i
          config.war_file = 'trisano.war'
        end.war.build
        FileUtils.mv('trisano.war', '../distro')
        puts "Success packaging trisano.war"
      end
    end

    desc "Migrate the database"
    task :upgrade_db => ['dump_db'] do
      initialize_config
      db_config_options = { :environment => @environment,
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @priv_uname,
        :password => @priv_password
      }

      with_replaced_database_yml(db_config_options) do
        cd '../webapp/'
        ruby "-S rake db:migrate RAILS_ENV=#{@environment}"
        puts "resetting db permissions"
        cd '../distro/'
        raise "failed to set db permissions" if !create_db_permissions
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

    desc "Starts a server instance based on the current distro config."
    task :server do
      initialize_config
      db_config_options = {
        :environment => @environment,
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @trisano_user,
        :password => @trisano_user_pwd
      }
      with_replaced_database_yml(db_config_options) do
        sh("script/runner -e #{@environment} script/set_default_admin_uid.rb")
        sh("script/server -e #{@environment}")
      end
    end
  end
end
