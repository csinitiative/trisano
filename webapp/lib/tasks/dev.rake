# Copyright (C) 2007, 2008, The Collaborative Software Foundation
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

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'yaml'
require 'erb'

namespace :trisano do

  namespace :dev do

    def core_db_rebuild_tasks
      config = YAML::load_file "../distro/config.yml"
      postgres_dir = config['postgres_dir'] unless validate_config_attribute(config, 'postgres_dir')
      psql = postgres_dir + "/psql"
      createdb = postgres_dir + "/createdb"
      dropdb = postgres_dir + "/dropdb"
      priv_uname = config['priv_uname'] unless validate_config_attribute(config, 'priv_uname')
      priv_password = config['priv_passwd'] unless validate_config_attribute(config, 'priv_passwd')
      ENV["PGPASSWORD"] = priv_password

      db_config = YAML::load(ERB.new(File.read('./config/database.yml')).result)
      if db_config['development'].nil?
        raise "Development environment is not defined."
      end
      host = db_config['development']['host']
      port = db_config['development']['port']
      database = db_config['development']['database']
      puts "doing full rebuild of all databases"
      sh "#{dropdb} -U #{priv_uname} -h #{host} -p #{port} #{database}; #{createdb} -U #{priv_uname} -h #{host} -p #{port} -E UTF8 #{database}" do |ok, res|
        if ! ok
          raise "Failed creating database: #{database} with error #{res.exitstatus}"
        end
      end
      ruby "-S rake db:drop:all"
      ruby "-S rake db:create:all"
      ruby "-S rake db:schema:load"
      ruby "-S rake db:migrate"
    end

    desc "full rebuild of all databases"
    task :db_rebuild_full do
      core_db_rebuild_tasks
      Rake::Task["trisano:dev:load_codes_and_defaults"].invoke
      Rake::Task["trisano:dev:load_test_and_demo_data"].invoke
      Rake::Task["db:test:prepare"].invoke
    end

    desc "full rebuild of all databases for a release"
    task :release_db_rebuild_full do
      core_db_rebuild_tasks
      Rake::Task["trisano:dev:load_codes_and_defaults"].invoke
      Rake::Task["db:test:prepare"].invoke
    end

    # may be able to delete this - 24-oct-08: build box no longer using
    desc "full rebuild of all databases for the build server"
    task :db_rebuild_full_for_build  => ['trisano:deploy:stoptomcat', 'db_rebuild_full'] do
    end

    desc "update locale configs"
    task :update_locale_configs => [:update_dev_locale_config, :update_test_locale_config] do
    end

    desc "update dev locale config"
    task :update_dev_locale_config do
      update_locale_config
    end

    desc "update test locale config"
    task :update_test_locale_config do
      update_locale_config("trisano_test")
    end

    def update_locale_config()
      sh("#{@psql} -U #{@priv_uname} -h #{@host} -p #{@port} #{@database} -e -c \"UPDATE pg_ts_cfg SET LOCALE = current_setting('lc_collate') WHERE ts_name = 'default'\"") do |ok, res|
        if ! ok
          puts "Failed updating locale config: #{@database} with error #{res.exitstatus}"
        end
      end

    end

    desc "Load codes and defauts into database"
    task :load_codes_and_defaults => [:load_codes, :load_defaults] do
    end

    desc "Load codes into database"
    task :load_codes do
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_codes.rb"
    end

    desc "Load defaults into database"
    task :load_defaults do
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_defaults.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/set_default_admin_uid.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_common_test_types.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_loinc_codes.rb #{RAILS_ROOT}/db/defaults/loinc_codes_to_common_test_types.csv"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_diseases.rb #{RAILS_ROOT}/db/defaults/diseases.yml"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_cdc_export_data.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_cdc_export_data_for_disease_core.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_disease_export_statuses.rb"
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_csv_defaults.rb"
    end

    desc "Load test/demo data"
    task :load_test_and_demo_data do
      ruby "#{RAILS_ROOT}/script/runner #{RAILS_ROOT}/script/load_test_and_demo_data.rb"
    end

    desc "Resets the database for cuke runs"
    task :db_reset do
      ruby "-S rake db:test:prepare"
    end

    # Debt: dry this up
    desc "Prep work for feature (cucumber) runs"
    task :feature_prep => ["trisano:dev:db_reset"] do
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_codes.rb"
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_defaults.rb"
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/set_default_admin_uid.rb"
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_common_test_types.rb"
      ruby "#{RAILS_ROOT}/script/runner -e test #{RAILS_ROOT}/script/load_test_and_demo_data.rb"
    end

    desc "Run standard features"
    task :standard_features do
      sh "cucumber features/standard -n -p standard"
    end

    desc "Run enhanced features"
    task :enhanced_features do
      sh "cucumber -p enhanced #{ENV['FEATURE'] || 'features/enhanced'}"
    end

  end

end
