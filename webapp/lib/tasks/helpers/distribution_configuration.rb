require 'yaml'
require 'rake/tasklib'

module Tasks::Helpers

  class DistributionConfiguration
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

    %w{host port database postgres_dir priv_uname priv_passwd trisano_uname trisano_user_passwd environment basicauth min_runtime max_runtimes runtime_timeout}.each do |attr|
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
      system("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -c 'GRANT ALL ON SCHEMA public TO #{trisano_uname}'") and
        system("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -e -f #{distro_dir}/database/load_grant_function.sql") and
        system("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -e -c \"SELECT pg_grant('#{trisano_uname}', 'all', '%', 'public')\"") or
        raise "Failed to grant permissions for #{trisano_uname}"
    end

    def create_db 
      system( "#{psql} -U #{priv_uname} -h #{host} -p #{port} postgres -e -c \"CREATE DATABASE #{database} ENCODING='UTF8'\"") or
        raise "Failed to create database"
    end

    def load_db_schema
      system("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -e -f #{distro_dir('database/trisano_schema.sql')}") or
        raise "Failed to load database" 
    end

    def load_dump
      dumpfile = File.expand_path dump_file_name, distro_dir('dump')
      sh("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} < #{dumpfile}") do |ok, res|
        raise "Failed importing dumpfile: #{dump_file} into database #{database} with error #{res.exitstatus}" unless ok
      end
    end

    def create_db_user
      unless db_user_exists?
        system("#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -c \"CREATE USER #{trisano_uname} ENCRYPTED PASSWORD '#{trisano_user_passwd}'\"")
      end
    end

    def db_user_exists?
      %x[#{psql} -U #{priv_uname} -h #{host} -p #{port} #{database} -c "SELECT usename FROM pg_user WHERE usename = '#{trisano_uname}'"] =~ /1 row/
    end

    def drop_db
      unless system "#{psql} -U #{priv_uname} -h #{host} -p #{port} postgres -e -c 'DROP DATABASE IF EXISTS #{database}'"
        raise "Failed to drop database"
      end
    end

    def drop_db_user
      unless system "#{psql} -U #{priv_uname} -h #{host} -p #{port} postgres -e -c 'DROP USER IF EXISTS #{trisano_uname}'"
        raise "Failed to drop user"
      end
    end

    def dump_db_to_file file_name=nil
      file_name ||= "dump/#{timstamp_dump_name}"
      file_name = File.expand_path file_name, distro_dir
      File.makedirs File.dirname(file_name), :verbose
      # dump sans access privs/acl & sans object owner - we grant auth on restore to make moving dump files between envIRONments easier
      File.open(file_name, 'w') {|f| f.write("\\set ON_ERROR_STOP\n\n") }
      unless system("#{pg_dump} -U #{priv_uname} -h #{host} -p #{port} #{database} -x -O >> #{file_name}")
        raise "Failed to dump database"
      end
    end

    def timestamp_dump_name
      timestamp = Time.now.strftime "%m-%d-%Y-%I%M%p"
      "#{database}-#{timestamp}.dump"
    end

    def migrate
      with_replaced_database_yml privileged_db_config do
        ruby "-S rake db:migrate RAILS_ENV=#{environment} &> #{distro_dir('upgrade_db_output.txt')}"
        create_db_permissions
      end
    end

    def set_default_admin
      with_replaced_database_yml privileged_db_config do
        ruby "#{app_dir('script/runner')} #{app_dir('script/set_default_admin_uid.rb')}"
      end
    end

    private

    def repo_root file_name
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

  end
end
