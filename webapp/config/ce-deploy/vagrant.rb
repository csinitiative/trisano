set :deploy_to, "~/#{application}"
role :app, "vagrant"
role :web, "vagrant"
role :db,  "vagrant", :primary => true
set :port, 2222

before 'deploy:migrate', "deploy:dump_db"
before "deploy:rollback",  "deploy:restore_db"

namespace :deploy do
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

