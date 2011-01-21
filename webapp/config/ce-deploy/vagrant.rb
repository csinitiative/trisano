set :deploy_to, "/home/vagrant/#{application}"
role :app, "vagrant"
role :web, "vagrant"
role :db,  "vagrant", :primary => true
set :port, 2222

# configure the database.yml
set :database, 'trisano_production'
set :username, 'trisano_user'
set :password, 'password'
set :database_host, 'localhost'

