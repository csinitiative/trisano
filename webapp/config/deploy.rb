require 'capistrano/ext/multistage'

set :application, "TriSano"
set :stages, %w(vagrant tomcat)
set :default_stage, "vagrant"

set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git"]

depend :remote, :command, "rake"
depend :remote, :command, "bundle"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
