# Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012, 2013 The Collaborative Software Foundation
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
require 'yaml'
require 'sparrowhawk'

module Tasks::Helpers

  class Distribution
    class << self
      def default_distro
        load_from_file default_config_file
      end
      
      def load_from_file config_file
        new YAML::load_file(config_file)
      end

      def default_config_file
        @default_config_file ||= File.expand_path('config.yml', distro_dir)
      end

      def repo_root
        @repo_root ||= ENV['TRISANO_REPO_ROOT'] || File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', '..'))
      end

      def distro_dir
        File.expand_path 'distro', repo_root 
      end
        
    end
    
    attr_reader :options

    %w{host port database postgres_dir priv_uname priv_passwd trisano_uname trisano_user_passwd environment basicauth min_runtimes max_runtimes runtime_timeout}.each do |attr|
      define_method attr do
        unless value = options[attr]
          raise "attribute #{attr} is not specified in config.yml - please add it and try again"
        end
        value
      end
    end

    %w{dump_file_name support_url source_url feedback_url feedback_email default_admin_uid}.each do |attr|
      define_method attr do
        options[attr]
      end
    end

    def initialize options
      @options = options.stringify_keys
      ENV["PGPASSWORD"] = priv_passwd 
    end

    def psql
      File.expand_path 'psql', postgres_dir
    end

    def pg_dump
      File.expand_path 'pg_dump', postgres_dir
    end

    def distro_dir file_name=''
      File.expand_path file_name, self.class.distro_dir
    end

    def create_db_permissions 
      system("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -c 'GRANT ALL ON SCHEMA public TO #{trisano_uname}'") and
        system("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -e -f #{distro_dir}/database/load_grant_function.sql") and
        system("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -e -c \"SELECT pg_grant('#{trisano_uname}', 'all', '%', 'public')\"") or
        raise "Failed to grant permissions for #{trisano_uname}"
    end

    def create_db 
      system( "#{psql} -X -U #{priv_uname} -h #{host} -p #{port} postgres -e -c \"CREATE DATABASE #{database} ENCODING='UTF8'\"") or
        raise "Failed to create database"
    end

    def load_db_schema
      system("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -e -f #{distro_dir('database/trisano_schema.sql')}") or
        raise "Failed to load database" 
    end

    def load_dump
      dumpfile = File.expand_path dump_file_name, distro_dir('dump')
      sh("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} < #{dumpfile}") do |ok, res|
        raise "Failed importing dumpfile: #{dump_file} into database #{database} with error #{res.exitstatus}" unless ok
      end
    end

    def create_db_user
      unless db_user_exists?
        system("#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -c \"CREATE USER #{trisano_uname} ENCRYPTED PASSWORD '#{trisano_user_passwd}'\"")
      end
    end

    def db_user_exists?
      %x[#{psql} -X -U #{priv_uname} -h #{host} -p #{port} #{database} -c "SELECT usename FROM pg_user WHERE usename = '#{trisano_uname}'"] =~ /1 row/
    end

    def drop_db
      unless system "#{psql} -X -U #{priv_uname} -h #{host} -p #{port} postgres -e -c 'DROP DATABASE IF EXISTS #{database}'"
        raise "Failed to drop database"
      end
    end

    def drop_db_user
      unless system "#{psql} -X -U #{priv_uname} -h #{host} -p #{port} postgres -e -c 'DROP USER IF EXISTS #{trisano_uname}'"
        raise "Failed to drop user"
      end
    end

    def dump_db_to_file file_name=nil
      file_name ||= "dump/#{timestamp_dump_name}"
      file_name = File.expand_path file_name, distro_dir
      File.makedirs File.dirname(file_name), :verbose
      # dump sans access privs/acl & sans object owner - we grant auth on restore to make moving dump files between envIRONments easier
      File.open(file_name, 'w') {|f| f.write("\\set ON_ERROR_STOP\n\n") }
      unless system("#{pg_dump} -U #{priv_uname} -h #{host} -p #{port} #{database} -x -O >> #{file_name}")
        raise "Failed to dump database"
      end
    end

    def timestamp_dump_name
      "#{database}-#{timestamp}.dump"
    end

    def migrate
      with_replaced_database_yml privileged_db_config do
        ruby "-S rake db:migrate RAILS_ENV=#{environment} > #{distro_dir('upgrade_db_output.txt')}"
        create_db_permissions
      end
    end

    def set_default_admin
      with_replaced_database_yml privileged_db_config do
        ruby "#{app_dir('script/runner')} -e #{environment} #{app_dir('script/set_default_admin_uid.rb')}"
      end
    end

    def overwrite_urls
      if support_url
        puts "overwriting TriSano Support URL with #{support_url}"
        change_text_in_file app_dir('app/helpers/layout_helper.rb'), "http://www.trisano.org/collaborate/\'", "#{support_url}\'"
      end
      if feedback_url
        puts "overwriting TriSano Feedback URL with #{feedback_url}"
        change_text_in_file app_dir('app/helpers/layout_helper.rb'), "http://groups.google.com/group/trisano-user", feedback_url
        change_text_in_file app_dir('app/controllers/application_controller.rb'), "http://groups.google.com/group/trisano-user", feedback_url
        change_text_in_file app_dir('public/500.html'), "http://groups.google.com/group/trisano-user", feedback_url
        change_text_in_file app_dir('public/503.html'), "http://groups.google.com/group/trisano-user", feedback_url
      end
      if feedback_email
        puts "overwriting TriSano Feedback email with #{feedback_email}"
        change_text_in_file(app_dir('app/helpers/layout_helper.rb'), "trisano-usergooglegroups.com", feedback_email)
      end
      if source_url
        puts "overwriting TriSano Source URL with #{source_url}"
        change_text_in_file(app_dir('app/helpers/layout_helper.rb'), "http://github.com/csinitiative/trisano/tree/master", source_url) 
      end
    end

    def create_war
      with_replaced_database_yml trisano_user_db_config do
        Sparrowhawk::Configuration.new do |config|
          config.other_files = FileList[app_dir('Rakefile')]
          config.application_dirs = %w(app config lib vendor db script)
          config.environment = environment
          config.runtimes = min_runtimes.to_i..max_runtimes.to_i
          config.war_file = war_file
        end.war.build
        FileUtils.mv war_file, distro_war_file
      end
    end

    def create_tar without_war = true
      filename = "trisano-release-#{timestamp}.tar.gz"
      dist_dirname = working_dir timestamp
      File.makedirs dist_dirname

      sh "cp -R #{repo_root}/* #{dist_dirname}"

      sh "rm -rf #{dist_dirname}/.git"

      # tried to get tar --exclude to work, but had no luck - bailing to a simpler approach
      cd dist_dirname

      File.delete "./webapp/#{war_name}" if File.file? "./webapp/#{war_name}"
      File.delete "./distro/#{war_name}" if File.file? "./distro/#{war_name}" and without_war

      sh "rm -f ./webapp/log/*.*"
      sh "rm -rf ./webapp/nbproject"
      sh "rm -rf ./distro/dump"
      sh "rm -rf ./webapp/tmp"
      sh "rm -rf ./distro/*.txt"
      sh "rm -rf ./webapp/vendor/plugins/safe_record"
      sh "rm -rf ./webapp/vendor/plugins/safe_erb"

      cd working_dir
      sh "tar czfh #{filename} ./#{timestamp}"
    end

    def war_exists?
      File.file? war_file 
    end
    
    def war_name
      'trisano.war'
    end

    def war_file
      app_dir war_name
    end

    def distro_war_exists?
      File.file? distro_war_file
    end

    def distro_war_file
      distro_dir war_name
    end

    private

    def working_dir file_name=''
      @working_dir ||= ENV['TRISANO_DIST_DIR'] || '~/trisano-dist'
      File.expand_path file_name, @working_dir
    end

    def repo_root file_name=''
      File.expand_path file_name, self.class.repo_root
    end

    def config_dir file_name=''
      File.expand_path file_name, app_dir('config')
    end

    def app_dir file_name=''
      File.expand_path file_name, repo_root('webapp')
    end

    def replace_database_yml(options)
      puts "creating database.yml based on contents of config.yml in #{config_dir}"
      db_config = {
        options[:environment] => {
          'adapter' => 'postgresql',
          'encoding' => 'unicode', 
          'database' => options[:database],
          'username' => options[:user],
          'password' => options[:password],
          'host' => options[:host],
          'port' => options[:port]
        }      
      }
      File.open(config_dir("database.yml"), "w") { |file| file.puts(db_config.to_yaml) }
    end

    def privileged_db_config
      Hash[:environment ,  environment,
           :host        ,  host,
           :port        ,  port,
           :database    ,  database,
           :user        ,  priv_uname,
           :password    ,  priv_passwd]
    end

    def trisano_user_db_config
      Hash[:environment , environment,
           :host        , host,
           :port        , port,
           :database    , database,
           :user        , trisano_uname,
           :password    , trisano_user_passwd]
    end

    def with_replaced_database_yml(options)
      backup_database_yml
      replace_database_yml(options)
      yield if block_given?
    ensure
      restore_database_yml
    end

    def backup_database_yml
      File.copy(config_dir("database.yml"), config_dir("database.yml.bak"), true)
    end

    def restore_database_yml
      File.move(config_dir("database.yml.bak"), config_dir("database.yml"), true)
    end

    def change_text_in_file(file, regex, replacement)
      text = File.read file
      File.open(file, 'w+'){ |io| io << text.gsub(regex, replacement) }
    end

    def timestamp
      @timestamp ||= Time.now.strftime "%m-%d-%Y-%I%M%p"
    end

  end
end
