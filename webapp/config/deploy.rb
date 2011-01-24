$:.unshift(File.expand_path('../lib', File.dirname(__FILE__))).uniq!
require 'capistrano/ext/multistage'
require 'capistrano/helpers'

extend Capistrano::Helpers::Prompts
extend Capistrano::Helpers::SiteConfig

default_run_options[:pty] = true
set :application, "TriSano"
set :deploy_to, "/opt/csi/#{application}"
set :stages, %w(vagrant tomcat)
set :default_stage, "vagrant"

set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git"]
set :copy_compression, :zip

depend :remote, :command, "rake"
depend :remote, :command, "bundle"

after 'deploy:update_code', 'deploy:update_database_yml'
after 'deploy:update_code', 'deploy:update_site_config_yml'

before 'deploy:migrate', "deploy:dump_db"
before "deploy:rollback",  "deploy:restore_db"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :update_database_yml, :roles => :app do
    require 'erb'
    require 'yaml'
    rails_env = fetch :rails_env, 'production'

    db_config = YAML::load ERB.new(IO.read("config/database.yml.sample")).result(binding)
    db_config.keys.each { |key| db_config.delete(key) unless key == rails_env }

    ask_for :database, 'Database name:'
    ask_for :username, 'Database user:'
    ask_for :host,     'Database host:'
    ask_for_password :password, 'Database password:'

    db_config[rails_env]['database'] = database
    db_config[rails_env]['username'] = username
    db_config[rails_env]['password'] = password
    db_config[rails_env]['host']     = database_host

    put db_config.to_yaml, "#{release_path}/config/database.yml"
  end

  task :update_site_config_yml, :roles => :app do
    require 'yaml'
    rails_env = fetch :rails_env, 'production'
    site_config = YAML::load_file("config/site_config.yml.sample")
    site_config[rails_env] = site_config['base'].merge(site_config[rails_env])
    site_config.keys.each { |key| site_config.delete(key) unless key == rails_env }

    site_config[rails_env] = update_site_config site_config[rails_env]
    put site_config.to_yaml, "#{release_path}/config/site_config.yml"
  end

  desc <<-DESC
    Deploys a new, fresh install of the application. Assumes a running \
    application server and database server, but no previously deployed \
    application code or trisano application database. Deploys the \
    application code, builds an application database, and restarts the \
    application server.
  DESC
  task :cold do
    rails_env = fetch :rails_env, 'production'
    update
    run "cd #{latest_release} && rake db:setup RAILS_ENV=#{rails_env}"
    restart
  end
  
  desc "Dumps the database before running migrations"
  task :dump_db do
    rails_env = fetch :rails_env, 'production'
    run "cd #{latest_release} && rake db:dump RAILS_ENV=#{rails_env}"
  end

  desc "Restores the db from the a dump if the dump is available"
  task :restore_db do
    rails_env = fetch :rails_env, 'production'
    run "cd #{latest_release} && rake db:restore RAILS_ENV=#{rails_env}"
  end

end
