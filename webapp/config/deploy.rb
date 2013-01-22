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
$:.unshift(File.expand_path('../lib', File.dirname(__FILE__))).uniq!
require 'capistrano/ext/multistage'
require 'capistrano/helpers'
require 'bundler/capistrano'

extend Capistrano::Helpers::Prompts
extend Capistrano::Helpers::SiteConfig

default_run_options[:pty] = true
set :application, "TriSano"
set :deploy_to, "/opt/#{application}"
set :user, "trisano_rails"
set :use_sudo, true
set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git", "log"]
set :copy_compression, :zip
set :ssh_options, {:forward_agent => true}
depend :remote, :command, "rake"
depend :remote, :command, "bundle"

after 'deploy:update_code', 'deploy:update_database_yml'
after 'deploy:update_code', 'deploy:update_site_config_yml'


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
    ask_for_password :database_password, 'Database password:'

    db_config[rails_env]['database'] = database
    db_config[rails_env]['username'] = username
    db_config[rails_env]['password'] = database_password
    db_config[rails_env]['host']     = database_host

    put db_config.to_yaml, "#{release_path}/config/database.yml"
  end

  task :update_site_config_yml, :roles => :app do
    rails_env = fetch :rails_env, 'production'
    site_config = { rails_env => generate_site_config }
    put site_config.to_yaml, "#{release_path}/config/site_config.yml"
  end

  task :refresh_site_config_yml, :roles => :app do
    rails_env = fetch :rails_env, 'production'
    site_config = { rails_env => generate_site_config }
    put site_config.to_yaml, "#{current_path}/config/site_config.yml"
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
    run "cd #{latest_release} && bundle exec rake db:setup RAILS_ENV=#{rails_env}"
    restart
  end
  
  desc "Dumps the database before running migrations"
  task :dump_db, :roles => :app do
    rails_env = fetch :rails_env, 'production'
    run "cd #{latest_release} && bundle exec rake db:dump RAILS_ENV=#{rails_env}"
  end

  desc "Restores the db from the a dump if the dump is available"
  task :restore_db do
    rails_env = fetch :rails_env, 'production'
    run "cd #{latest_release} && bundle exec rake db:restore RAILS_ENV=#{rails_env}"
  end

  desc "Reloads Core Field data"
  task :core_fields do
    rails_env = fetch :rails_env, 'production'
    run "cd #{latest_release} && bundle exec rake db:load_core_fields RAILS_ENV=#{rails_env}"
  end


end
