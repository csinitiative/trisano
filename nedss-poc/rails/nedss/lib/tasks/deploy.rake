require 'ftools'
require 'fileutils'
require 'mechanize'
require 'rexml/document'
require 'rest-open-uri'
require 'logger'

namespace :nedss do

  namespace :deploy do
    WAR_FILE_NAME = 'nedss.war'
    # Override with env variable if you have a different Tomcat home - just export it
    TOMCAT_HOME = ENV['TOMCAT_HOME'] ||= '/opt/tomcat/apache-tomcat-6.0.14' 
    TOMCAT_BIN = TOMCAT_HOME + '/bin'
    TOMCAT_DEPLOY_DIR_NAME = TOMCAT_HOME + '/webapps'
    TOMCAT_DEPLOYED_EXPLODED_WAR_DIR = TOMCAT_DEPLOY_DIR_NAME + '/' + 'nedss'
    TOMCAT_DEPLOYED_WAR_NAME = TOMCAT_DEPLOY_DIR_NAME + '/' + WAR_FILE_NAME
    # Override with env variable if you are running locally http://localhost:8080
    NEDSS_URL = ENV['NEDSS_URL'] ||= 'http://ut-nedss-dev.csinitiative.com'

    desc "delete nedss war file and exploded directory from Tomcat"
    task :deletewar do
      puts "attempting to delete war file from Tomcat"
      if File.file? TOMCAT_DEPLOYED_WAR_NAME
        File.delete(TOMCAT_DEPLOYED_WAR_NAME) 
        puts "deleted deployed war file"
      else
        puts "war file not found - did not delete"
      end

      puts "attempting to delete deployed exploded war directory"
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
    
    desc "copy nedss war file to Tomcat"
    task :copywar do
      puts "attempting to copy war file to Tomcat"
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

    desc "smoke test that ensures NEDSS was deployed"
    task :smoke do
      retries = 5
      begin
        sleep 10
        puts "executing smoke test"
        people_url = NEDSS_URL + '/nedss/entities?type=person'
        puts people_url

        #agent = WWW::Mechanize.new {|a| a.log = Logger.new(STDERR) }
        agent = WWW::Mechanize.new 
        agent.basic_auth('utah', 'arches')
        #agent.set_proxy("localhost", "8118")
        page = agent.get people_url

        new_person_url = NEDSS_URL + '/nedss/entities/new?type=person'
        puts new_person_url
        page = agent.get new_person_url

        puts "POST CMR"
        new_event_url = NEDSS_URL + '/nedss/cmrs/new'
        
        page = agent.get(new_event_url)
        form = page.forms.first
        #form.fields.each { |f| puts f.name }

        # Set minimal values
        form['event[active_patient][active_primary_entity][person][first_name]'] = 'Steve'
        form['event[active_patient][active_primary_entity][person][last_name]'] = 'Smoker'

        # Hack Mechanize to send some blank drop values so Rails doesn't have a fit
        # Firefox sends these as blanks, but mechanize doesn't so I have to do it manually
        form.add_field!("event[active_patient][active_primary_entity][person][birth_gender_id]", "")
        form.add_field!("event[active_patient][active_primary_entity][person][ethnicity_id]", "")
        form.add_field!("event[active_patient][active_primary_entity][person][primary_language_id]", "")
        form.add_field!("event[active_patient][active_primary_entity][address][state_id]", "")
        form.add_field!("event[active_patient][active_primary_entity][address][county_id]", "")
        form.add_field!("event[active_hospital][secondary_entity_id]", "")
        form.add_field!("event[active_jurisdiction][secondary_entity_id]", "")

        page = agent.submit form      
               
        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end

    desc "revised post"
    
    task :post do
      puts "posting"

      agent = WWW::Mechanize.new
      agent.basic_auth('utah', 'arches')
      page = agent.get("http://localhost:8080/nedss/cmrs/new")
      form = page.forms.first
      #form.fields.each { |f| puts f.name }

      # Set minimal values
      form['event[active_patient][active_primary_entity][person][first_name]'] = 'Steve'
      form['event[active_patient][active_primary_entity][person][last_name]'] = 'Smoker'

      # Hack Mechanize to send some blank drop values so Rails doesn't have a fit
      # Firefox sends these as blanks, but mechanize doesn't so I have to do it manually
      form.add_field!("event[active_patient][active_primary_entity][person][birth_gender_id]", "")
      form.add_field!("event[active_patient][active_primary_entity][person][ethnicity_id]", "")
      form.add_field!("event[active_patient][active_primary_entity][person][primary_language_id]", "")
      form.add_field!("event[active_patient][active_primary_entity][address][state_id]", "")
      form.add_field!("event[active_patient][active_primary_entity][address][county_id]", "")
      form.add_field!("event[active_hospital][secondary_entity_id]", "")
      form.add_field!("event[active_jurisdiction][secondary_entity_id]", "")

      page = agent.submit form      
    end

    desc "redeploy Tomcat"
    task :redeploytomcat => [:stoptomcat, :deletewar, :copywar, :starttomcat, :smoke] do
      puts "redeploy Tomcat success"
    end
    
    desc "build war and redeploy Tomcat"
    task :buildandredeploy => [:buildwar, :redeploytomcat] do
      puts "build and redeploy success"
    end
    
    desc "build and redeploy full: build and redeploy plus integration tests"
    task :buildandredeployfull => [:buildandredeploy, 'nedss:integration:run_all'] do
      puts "build, redeploy and integration test success"
    end

  end

end
