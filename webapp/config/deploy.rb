require 'capistrano/ext/multistage'

set :application, "TriSano"
set :stages, %w(vagrant tomcat)
set :default_stage, "vagrant"

set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git"]
set :copy_compression, :zip

depend :remote, :command, "rake"
depend :remote, :command, "bundle"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
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

end
