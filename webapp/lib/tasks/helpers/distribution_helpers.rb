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
module Tasks::Helpers
  module DistributionHelpers
    def distro
      @distro ||= Distribution.default_distro
    end

    def tomcat
      @tomcat = Tomcat.new
    end

    def start_tomcat
      tomcat.start_server
    end

    def stop_tomcat
      tomcat.stop_server { |stopped| sleep 30 if stopped }
    end

    def create_db
      distro.create_db
    end

    def load_db_schema
      distro.load_db_schema
    end

    def load_dump
      distro.load_dump
    end

    def create_db_user
      distro.create_db_user
    end

    def create_db_permissions
      distro.create_db_permissions
    end

    def drop_db
      distro.drop_db
    end

    def drop_db_user
      distro.drop_db_user
    end

    def dump_db_to_file file_name=nil
      distro.dump_db_to_file file_name
    end

    def migrate
      distro.migrate
    end

    def set_default_admin
      distro.set_default_admin
    end

    def overwrite_urls
      distro.overwrite_urls
    end

    def create_war
      distro.create_war
    end

    def distro_war_exists?
      distro.distro_war_exists?
    end

    def deploy_war
      File.move distro.distro_war_file, tomcat.webapp_dir, true
    end

    def undeploy_war
      tomcat.undeploy 'trisano'
    end

    def create_tar_without_war
      distro.create_tar
    end

    def create_tar
      distro.create_tar false
    end

    def repo_root
      Distribution.repo_root
    end
  end
end
