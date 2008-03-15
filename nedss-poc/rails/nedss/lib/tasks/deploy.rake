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
        agent.set_proxy("localhost", "8118")
        page = agent.get people_url

        new_person_url = NEDSS_URL + '/nedss/entities/new?type=person'
        puts new_person_url
        page = agent.get new_person_url

        new_event_url = NEDSS_URL + '/nedss/cmrs/new'
        puts new_event_url
        page = agent.get new_event_url

        new_cmr_url = NEDSS_URL  + '/nedss/cmrs'
        puts "POST #{new_cmr_url}"
        agent.post(new_cmr_url, "event[active_patient][active_primary_entity][person][first_name]" => "Steve", 
          "event[active_patient][active_primary_entity][person][last_name]" => "Smoke",
          "event[active_patient][active_primary_entity][entity_type]" => "person",
          "event[active_patient][active_primary_entity][entities_location][entity_id]" => "",
          "event[active_patient][active_primary_entity][entities_location][entity_location_type_id]" => "1303",
          "event[active_patient][active_primary_entity][entities_location][primary_yn_id]" => "1402",
          "event[active_patient][active_primary_entity][address][street_number]" => "",
          "event[active_patient][active_primary_entity][address][street_name]" => "",
          "event[active_patient][active_primary_entity][address][unit_number]" => "",
          "event[active_patient][active_primary_entity][address][city_id]" => "",
          "event[active_patient][active_primary_entity][address][state_id]" => "",
          "event[active_patient][active_primary_entity][address][county_id]" => "",
          "event[active_patient][active_primary_entity][address][district_id]" => "",
          "event[active_patient][active_primary_entity][address][postal_code]" => "",
          "event[active_patient][active_primary_entity][person][birth_date]" => "",
          "event[active_patient][active_primary_entity][person][approximate_age_no_birthday]" => "",
          "event[active_patient][active_primary_entity][person][date_of_death]" => "",
          "event[active_patient][active_primary_entity][telephone][area_code]" => "",
          "event[active_patient][active_primary_entity][telephone][phone_number]" => "",
          "event[active_patient][active_primary_entity][telephone][extension]" => "",
          "event[active_patient][active_primary_entity][person][birth_gender_id]" => "",
          "event[active_patient][active_primary_entity][person][current_gender_id]" => "", 
          "event[active_patient][active_primary_entity][person][ethnicity_id]" => "",
          "event[active_patient][active_primary_entity][person][primary_language_id]" => "",
          "event[active_patient][active_primary_entity][person][food_handler_id]" => "1401",
          "event[active_patient][active_primary_entity][person][healthcare_worker_id]" => "1401",
          "event[active_patient][active_primary_entity][person][group_living_id]" => "1401",
          "event[active_patient][active_primary_entity][person][day_care_association_id]" => "1401",
          "event[active_patient][active_primary_entity][person][risk_factors]" => "",
          "event[active_patient][active_primary_entity][person][risk_factors_notes]" => "",
          "event[disease][disease_id]" => "2",
          "event[disease][disease_onset_date]" => "",
          "event[disease][date_diagnosed]" => "",
          "event[disease][hospitalized_id]" => "1401",
          "event[active_hospital][secondary_entity_id]" => "",
          "event[active_hospital][hospitals_participation][admission_date]" => "",
          "event[active_hospital][hospitals_participation][discharge_date]" => "",
          "event[disease][died_id]" => "1401",
          "event[disease][pregnant_id]" => "1401",
          "event[disease][pregnancy_due_date]" => "",
          "event[imported_from_id]" => "2101",
          "event[active_patient][participations_treatment][treatment_given_yn_id]" => "1401",
          "event[active_patient][participations_treatment][treatment]" => "",
          "event[lab_result][lab_result_text]" => "",
          "event[lab_result][specimen_source_id]" => "1501",
          "event[lab_result][collection_date]" => "",
          "event[lab_result][lab_test_date]" => "",
          "event[lab_result][tested_at_uphl_yn_id]" => "1401",
          "event[active_reporting_agency][secondary_entity_id]" => "",
          "event[active_reporting_agency][active_secondary_entity][place][name]" => "",
          "event[active_reporter][active_secondary_entity][person][first_name]" => "",
          "event[active_reporter][active_secondary_entity][person][last_name]" => "",
          "event[active_reporter][active_secondary_entity][entities_location][entity_location_type_id]" => "1303",
          "event[active_reporter][active_secondary_entity][entities_location][primary_yn_id]" => "1402",
          "event[active_reporter][active_secondary_entity][telephone][area_code]" => "",
          "event[active_reporter][active_secondary_entity][telephone][phone_number]" => "",
          "event[active_reporter][active_secondary_entity][telephone][extension]" => "",
          "event[results_reported_to_clinician_date]" => "",
          "event[event_case_status_id]" => "1801",
          "event[outbreak_associated_id]" => "1401",
          "event[outbreak_name]" => "",
          "event[investigation_started_date]" => "",
          "event[investigation_LHD_status_id]" => "1701",
          "event[investigation_completed_LHD_date]" => "",
          "event[first_reported_PH_date]" => "",
          "event[review_completed_UDOH_date]" => "",
          "event[active_jurisdiction][secondary_entity_id]" => "",
          "event[event_onset_date]" => "March 15, 2008",
          "event[event_name]" => "",
          "event[event_type_id]" => "2001",
          "event[event_status_id]" => "1901",
          "commit" => "Create"
        )

        puts "smoke test success"
      rescue => error
        puts error
        puts "smoke test retry attempts remaining: #{retries - 1}"
        retry if (retries -= 1) > 0
        raise
      end
    end
    
    # This will still indicate success even if there was a faliure. Needs to be remedied
    desc "run the integration tests"
    task :runintegration => 'nedss:integration:run_all' do
      puts "integration test success"
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
    task :buildandredeployfull => [:buildandredeploy, :runintegration] do
      puts "build, redeploy and integration test success"
    end

  end

end
