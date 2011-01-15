set :deploy_to, "~/#{application}"
role :app, "vagrant"
role :web, "vagrant"
role :db,  "vagrant", :primary => true
set :port, 2222

namespace :deploy do
  desc <<-DESC
    Replaces the default deploy w/ one that builds a war and deploys \
    it to a Tomcat server.
  DESC
  task :default do
    update
    tomcat.stop
    transaction do
      tomcat.undeploy_war
      tomcat.deploy_war
    end
    tomcat.start
  end

  namespace :tomcat do
    desc "Stop tomcat on the server. Assumes an /etc/init.d style script"
    task :stop do
      tomcat_script = fetch('tomcat_script', '/etc/init.d/tomcat6')
      try_sudo "#{tomcat_script} stop"
    end

    desc "Start tomcat on the server. Assumes an /etc/init.d style script"
    task :start do
      tomcat_script = fetch('tomcat_script', '/etc/init.d/tomcat6')
      try_sudo "#{tomcat_script} start"
    end

    desc "Builds the war and deploys it to tomcat_deploy_to"
    task :deploy_war do
      tomcat_deploy_to = fetch('tomcat_deploy_to', '/var/lib/tomcat6/webapps')
      rails_env = fetch(:rails_env, 'production')
      run "cd #{current_path} && rake war RAILS_ENV=#{rails_env}"
      try_sudo "mv #{current_path}/trisano.war #{tomcat_deploy_to}/trisano.war"
    end

    desc "Removes the currently deployed war from tomcat_deploy_to"
    task :undeploy_war do
      tomcat_deploy_to = fetch('tomcat_deploy_to', '/var/lib/tomcat6/webapps')
      on_rollback do
        if File.file? "#{previous_release}/trisano.war"
          try_sudo "mv #{previous_relase}/trisano.war #{tomcat_deploy_to}/trisano.war"
        else
          puts "No previous war file to deploy. Skipping step"
        end
      end
      try_sudo "rm -rf #{tomcat_deploy_to}/trisano"
      if File.file? "#{tomcat_deploy_to}/trisano.war"
        try_sudo "rm #{tomcat_deploy_to}/trisano.war"
      end
    end
  end
end
