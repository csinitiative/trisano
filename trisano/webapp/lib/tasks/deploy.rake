require 'ftools'
require 'fileutils'
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'
require 'logger'

namespace :trisano do
  
  # Supported rake task arguments:
  # RAILS_ENV - controls what database config to use
  # basicauth - whether or not to use HTTP Basic Auth from within the .war file (default = true)
  # min - sets the minimum number of Rails instances in the pool (default is 4)
  # max - sets the maximum number of Rails instances in the pool (defaul is 10)
  # Example: jruby -S rake trisano:deploy:buildwar RAILS_ENV=production basicauth=false
  namespace :deploy do
    WAR_FILE_NAME = 'trisano.war'
    # Override with env variable if you have a different Tomcat home - just export it
    TOMCAT_HOME = ENV['TOMCAT_HOME'] ||= '/opt/tomcat/apache-tomcat-6.0.14' 
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'
    TOMCAT_DEPLOYED_EXPLODED_WAR_DIR = TOMCAT_DEPLOY_DIR_NAME + '/' + 'trisano'
    TOMCAT_DEPLOYED_WAR_NAME = TOMCAT_DEPLOY_DIR_NAME + '/' + WAR_FILE_NAME
    # Override with env variable if you are running locally http://localhost:8080
    TRISANO_URL = ENV['TRISANO_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'
    TRISANO_SVN_ROOT = ENV['TRISANO_SVN_ROOT'] ||= '~/projects/trisano'
    TRISANO_DIST_DIR = ENV['TRISANO_DIST_DIR'] ||= '~/trisano-dist'

    desc "delete trisano war file and exploded directory from Tomcat"
    task :deletewar do
      puts "attempting to delete war file from Tomcat"
      if File.file? TOMCAT_DEPLOYED_WAR_NAME
        File.delete(TOMCAT_DEPLOYED_WAR_NAME) 
        puts "deleted deployed war file"
      else
        puts "war file not found - did not delete"
      end

      puts "attempting to delete deployed exploded war directory #{TOMCAT_DEPLOYED_EXPLODED_WAR_DIR}"
      if File.directory? TOMCAT_DEPLOYED_EXPLODED_WAR_DIR 
        FileUtils.remove_dir(TOMCAT_DEPLOYED_EXPLODED_WAR_DIR)
        puts "deleted deployed exploded war directory"
      else
        puts "deployed exploded war directory not found - did not delete"
      end
    end

    desc "build war file"
    task :buildwar do
      puts "running warble clean"
      ruby "-S warble war:clean"
      puts "running warble war"
      ruby "-S warble war"
    end
    
    desc "copy trisano war file to Tomcat"
    task :copywar do
      puts "attempting to copy #{WAR_FILE_NAME} war file to Tomcat #{TOMCAT_DEPLOY_DIR_NAME}"
      if files_exist
        File.copy(WAR_FILE_NAME, TOMCAT_DEPLOY_DIR_NAME, true) 
      else
        which_files_exist
      end
    end

    def files_exist
      File.file? WAR_FILE_NAME
      File.directory? TOMCAT_DEPLOY_DIR_NAME
    end

    def which_files_exist
      puts "#{WAR_FILE_NAME} exists? #{File.file? WAR_FILE_NAME} #{TOMCAT_DEPLOY_DIR_NAME} exists? #{File.directory? TOMCAT_DEPLOY_DIR_NAME}"
    end

    desc "stop Tomcat"
    task :stoptomcat do
      puts "attempting to stop Tomcat"
      sh TOMCAT_BIN + "/shutdown.sh"
      sleep 10
    end

    desc "start Tomcat"
    task :starttomcat do
      puts "attempting to start Tomcat"
      sh TOMCAT_BIN + "/startup.sh"
    end

    desc "smoke test that ensures trisano was deployed"
    task :smoke do
      retries = 5
      begin
        sleep 10
        puts "executing smoke test"
        people_url = TRISANO_URL + '/trisano/entities?type=person'
        puts people_url

        Hpricot.buffer_size = 32768
        #agent = WWW::Mechanize.new {|a| a.log = Logger.new(STDERR) }
        agent = WWW::Mechanize.new 
        agent.basic_auth('utah', 'arches')
        #agent.set_proxy("localhost", "8118")
        page = agent.get people_url

        new_person_url = TRISANO_URL + '/trisano/entities/new?type=person'
        puts new_person_url
        page = agent.get new_person_url

        puts "POST CMR"
        new_event_url = TRISANO_URL + '/trisano/cmrs/new'
        page = agent.get(new_event_url)
        form = page.forms[1]
        #form.fields.each { |f| puts f.name }

        # Set minimal values
        form['morbidity_event[active_patient][active_primary_entity][person][first_name]'] = 'Steve'
        form['morbidity_event[active_patient][active_primary_entity][person][last_name]'] = 'Smoker'

        # Hack Mechanize to send some blank drop values so Rails doesn't have a fit
        # Firefox sends these as blanks, but mechanize doesn't so I have to do it manually
        form.add_field!("morbidity_event[disease][disease_id]", "")
        form.add_field!("morbidity_event[active_patient][active_primary_entity][person][birth_gender_id]", "")
        form.add_field!("morbidity_event[active_patient][active_primary_entity][person][ethnicity_id]", "")
        form.add_field!("morbidity_event[active_patient][active_primary_entity][person][primary_language_id]", "")
        form.add_field!("morbidity_event[active_patient][active_primary_entity][address][state_id]", "")
        form.add_field!("morbidity_event[active_patient][active_primary_entity][address][county_id]", "")
        form.add_field!("morbidity_event[active_jurisdiction][secondary_entity_id]", "")

        page = agent.submit form      
        raise "POST content invalid" unless (page.search("//#errorExplanation")).empty?
               
        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end

    desc "redeploy Tomcat"
    task :redeploytomcat => [:stoptomcat, :deletewar, :copywar, :starttomcat, :smoke] do
      puts "redeploy Tomcat success"
    end
    
    desc "build war and redeploy Tomcat"
    task :buildandredeploy => [:buildwar, :redeploytomcat] do
      puts "build and redeploy success"
    end
    
    desc "build and redeploy full: alias for build and redeploy"
    task :buildandredeployfull => [:buildandredeploy] do
      puts "build and redeploy"
    end

    desc "Create database configuration file"
    task :create_db_config do
      ruby "-S rake trisano:dev:db_rebuild_full RAILS_ENV=development"
      sh "pg_dump -c -O -c trisano_development > ../distro/trisano_schema.sql"
    end

    desc "package production .war file, include database dump, scripts, and configuration files in a .tar"
    task :release  do
      
      ruby "-S rake trisano:deploy:create_db_config"

      t = Time.now
      tformated = t.strftime("%m-%d-%Y-%I%M%p")
      filename = "trisano-release-" + t.strftime("%m-%d-%Y-%I%M%p") + ".tar.gz"
      dist_dirname = TRISANO_DIST_DIR + "/" + tformated
      
      sh "cp -R #{TRISANO_SVN_ROOT} #{dist_dirname}"

      p "removing .svn directories"
      sh "find #{dist_dirname} -name .svn -print0 | xargs -0 rm -rf"
      
      # tried to get tar --exclude to work, but had no luck - bailing to a simpler approach
      p "removing tmp directories"
      cd dist_dirname
      sh "rm -rf ./webapp/tmp"
      sh "rm ./webapp/log/*.*"
      sh "rm -rf ./webapp/nbproject"
      sh "rm -rf ./distro/dump"
      sh "rm ./distro/*.war"
      
      cd TRISANO_DIST_DIR
      sh "tar cvzf #{filename} ./#{tformated}"

    end
  end
end
