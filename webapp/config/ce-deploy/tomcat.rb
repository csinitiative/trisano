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
    tomcat.undeploy_trisano
    tomcat.build_war
    tomcat.start
  end

  namespace :tomcat do
    desc "Stop tomcat on the server. Assumes ~/tomcat6/bin/shutdown.sh"
    task :stop do
      tomcat_script = fetch('tomcat_script', '~/tomcat6/bin/shutdown.sh')
      run "#{tomcat_script}"
    end

    desc "Start tomcat on the server. Assumes ~/tomcat6/bin/startup.sh"
    task :start do
      tomcat_script = fetch('tomcat_script', '~/tomcat6/bin/startup.sh')
      run "#{tomcat_script}"
    end

    desc <<-DESC
      Builds the war. Ensures the the webapps directory has a symlink to \
      the current trisano.war. By default, this means making a link from \
      ~/TriSano/current/trisano.war to ~/tomcat6/webapps/trisano.war. \
      \
      The webapps directory can be changed by setting 'tomcat_deploy_to'.
    DESC
    task :build_war do
      tomcat_deploy_to = fetch('tomcat_deploy_to', '~/tomcat6/webapps')
      rails_env = fetch(:rails_env, 'production')
      on_rollback do
        run "rm -f #{current_path}/trisano.war"
        run "rm -f #{tomcat_deploy_to}/trisano.war"
        if File.exists? "#{previous_release}/trisano.war"
          run "ln -s #{previous_release}/trisano.war #{tomcat_deploy_to}/trisano.war"
        end
      end
      run "cd #{current_path} && rake war RAILS_ENV=#{rails_env}"
      run "rm -f #{tomcat_deploy_to}/trisano.war"
      run "ln -s #{current_path}/trisano.war #{tomcat_deploy_to}/trisano.war"
    end

    desc "Removes the exploded war from the webapps directory"
    task :undeploy_trisano do
      tomcat_deploy_to = fetch('tomcat_deploy_to', '~/tomcat6/webapps')
      on_rollback { run "rm -rf #{tomcat_deploy_to}/trisano" }
      run "rm -rf #{tomcat_deploy_to}/trisano"
    end
  end
end
