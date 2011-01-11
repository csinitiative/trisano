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

require 'ftools'
require 'fileutils'
require 'yaml'
require 'sparrowhawk'
require 'tasks/helpers'

namespace :tomcat do
  desc 'Start tomcat instance'
  task :start => 'trisano:tomcat:start'

  desc "Stop tomcat instance"
  task :stop => 'trisano:tomcat:stop'
end

namespace :distro do
  namespace :db do
    desc "Drop, restore, and migrate data dump"
    task :upgrade => 'trisano:distro:db:upgrade'
  end

  desc 'Create and deploy war'
  task :deploy => 'trisano:distro:deploy'

  desc "Create a tar for distribution"
  task :tar => 'trisano:distro:tar'

  desc "Create a war distribution"
  task :war => 'trisano:distro:war'

  namespace :test do
    desc "Full release path monty! Restores the db from a dump, migrates it, and then deploys the war to Tomcat"
    task :release => 'trisano:distro:test:release'
  end
end
  
namespace :trisano do
  def deploy_dir file_name=''
    File.join server_home, 'webapps', file_name
  end

  def trisano_host path=""
    host ||= ENV['TRISANO_URL'] || 'http://localhost:8080'
    File.join host, path
  end
 
  Tasks::Helpers::Tomcat.new

  namespace :distro do
    include Tasks::Helpers::DistributionHelpers

    def war_name
      'trisano.war'
    end

    def war_file
      File.join rakefile_dir, war_name
    end

    def repo_root
      @repo_root ||= ENV['TRISANO_REPO_ROOT'] || File.expand_path(rakefile_dir('..'))
    end

    def working_dir file_name=''
      @working_dir ||= ENV['TRISANO_DIST_DIR'] || '~/trisano-dist'
      File.expand_path File.join(@working_dir, file_name)
    end

    def change_text_in_file(file, regex_to_find, text_to_put_in_place)
      text= File.read file
      File.open(file, 'w+'){|f| f << text.gsub(regex_to_find, text_to_put_in_place)}
    end

    def core_release_tasks(delete_war = true)
      timestamp = Time.new.strftime "%m-%d-%Y-%I%M%p"
      filename = "trisano-release-#{timestamp}.tar.gz"
      dist_dirname = working_dir timestamp
      File.makedirs dist_dirname

      sh "cp -R #{repo_root}/ #{dist_dirname}"

      sh "rm -rf #{dist_dirname}/.git"

      # tried to get tar --exclude to work, but had no luck - bailing to a simpler approach
      cd dist_dirname

      if File.file? "./webapp/#{war_name}"
        File.delete "./webapp/#{war_name}"
        puts "deleted ./webapp/#{war_name}"
      end
      if File.file? "./distro/#{war_name}" and delete_war
        File.delete "./distro/#{war_name}"
        puts "deleted ./distro/#{war_name}"
      end
      sh "rm -f ./webapp/log/*.*"
      sh "rm -rf ./webapp/nbproject"
      sh "rm -rf ./distro/dump"
      sh "rm -rf ./webapp/tmp"
      sh "rm -rf ./distro/*.txt"
      sh "rm -rf ./webapp/vendor/plugins/safe_record"
      sh "rm -rf ./webapp/vendor/plugins/safe_erb"

      cd working_dir
      sh "tar czfh #{filename} ./#{timestamp}"
    end

    namespace :db do
      ## "Create a database based on the distribution configuration"
      task :create do
        create_db
        load_db_schema
        create_db_user 
        create_db_permissions
      end

      ## "Drop distribution database (and associated entities)"
      task :drop do
        drop_db 
        drop_db_user
      end

      ## "Export the distribution database"
      task :dump do
        dump_db_to_file
      end
 
      ## "Restore database from a dump file and apply currently configured distribution permission"
      task :restore do
        create_db
        load_dump
        create_db_user
        create_db_permissions
      end

      ## "Run migrations against the configured distribution database"
      task :migrate => [:dump] do
        migrate
      end

      task :upgrade => [:drop, :restore, :migrate, :set_default_admin]
      
      ## "Sometimes we do this to make sure we can get into a application instance
      task :set_default_admin do
        set_default_admin
      end

      ## "Create a database schema based on the current plugin configuration"
      task :schema do
        ruby "-S rake db:release:reset RAILS_ENV=development"
        #TODO: Do this in a throw away database and then throw it away
        dump_db_to_file 'database/trisano_schema.sql'
      end

      namespace :schema do
        ## "Create a database schema with demo data based on the current plugin configuration"
        task :demo do
          ruby "-S db:reset RAILS_ENV=development"
          dump_db_to_file 'database/trisano_schema.sql'
        end
      end
    end

    task :overwrite_footer_urls => :overwrite_urls

    ## "Overwrites hardcoded TriSano URLs with what is in the config.yml *_url attributes"
    task :overwrite_urls do
      puts "starting overwrite"
      initialize_config
      if ! @support_url.nil?
        puts "overwriting TriSano Support URL with #{@support_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://www.trisano.org/collaborate/\'", "#{@support_url}\'")
      end
      if ! @feedback_url.nil?
        puts "overwriting TriSano Feedback URL with #{@feedback_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/app/controllers/application_controller.rb', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/public/500.html', "http://groups.google.com/group/trisano-user", @feedback_url)
        change_text_in_file('../webapp/public/503.html', "http://groups.google.com/group/trisano-user", @feedback_url)
      end
      if ! @feedback_email.nil?
        puts "overwriting TriSano Feedback email with #{@feedback_email}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "trisano-user@googlegroups.com", @feedback_email)
      end
      if ! @source_url.nil?
        puts "overwriting TriSano Source URL with #{@source_url}"
        change_text_in_file('../webapp/app/helpers/layout_helper.rb', "http://github.com/csinitiative/trisano/tree/master", @source_url) 
      end
    end

    task :war => [:overwrite_urls] do
      initialize_config
      db_config_options = {
        :environment => @environment,
        :host => @host,
        :port => @port,
        :database => @database,
        :user => @trisano_user,
        :password => @trisano_user_pwd
      }
      with_replaced_database_yml(db_config_options) do
        Sparrowhawk::Configuration.new do |config|
          config.other_files = FileList[rakefile_dir('Rakefile')]
          config.application_dirs = %w(app config lib vendor db script)
          config.environment = @environment
          config.runtimes = @min_runtimes.to_i..@max_runtimes.to_i
          config.war_file = rakefile_dir(war_name)
        end.war.build
        FileUtils.mv rakefile_dir(war_name), distro_dir
      end
    end

    namespace :war do
      task :deploy do
       Rake::Task['distro:war'].invoke unless File.file? distro_dir(war_name)
       File.move distro_dir(war_name), deploy_dir, true
      end

      task :undeploy do
        File.delete deploy_dir(war_name) if File.file? deploy_dir(war_name)
        FileUtils.remove_dir deploy_dir('trisano') if File.directory? deploy_dir('trisano')
      end
    end
 
    task :deploy => ['tomcat:stop', 'trisano:distro:war:undeploy', 'trisano:distro:war:deploy', 'trisano:tomcat:start']

    task :tar do
      puts "!!WARNING!!: using following TRISANO_REPO_ROOT #{repo_root}. Please ensure it is correct."
      ruby "-S rake trisano:distro:db:schema"
      ruby "-S rake trisano:distro:war"
      core_release_tasks false
    end

    namespace :tar do
      ## "Create a tar with demo data for distribution"
      task :demo do
        puts "!!WARNING!!: using following TRISANO_REPO_ROOT #{repo_root}. Please ensure it is correct."
        puts "==================== This release will include test/demo data. ===================="
        puts "==================== It is not intended to be used for a clean system install ====="
        ruby "-S rake trisano:distro:db:schema:demo"
        core_release_tasks
      end
    end
 
    namespace :test do
      task :release => ['tomcat:stop', 'trisano:distro:db:upgrade', 'trisano:distro:deploy', 'trisano:distro:smoke']
    end

    ## "smoke test that ensures trisano was deployed"
    task :smoke do
      require 'mechanize'
      retries = 5
      url = trisano_host('trisano')
      begin
        sleep 10

        agent = WWW::Mechanize.new
        agent.read_timeout = 300

        puts "GET / to #{url}"
        page = agent.get(url)

        raise "GET content invalid" unless (page.search("#errorExplanation")).empty?

        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end
  end
end
