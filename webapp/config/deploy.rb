require 'capistrano/ext/multistage'

set :application, "TriSano"
set :default_stage, "vagrant"

set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git"]

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart do ; end
#  task :restart, :roles => :app, :except => { :no_release => true } do
#    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#  end
end
