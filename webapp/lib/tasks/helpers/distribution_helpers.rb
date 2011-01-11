module Tasks::Helpers
  module DistributionHelpers
    def distro
      @distro ||= DistributionConfiguration.default_distro
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
  end
end
