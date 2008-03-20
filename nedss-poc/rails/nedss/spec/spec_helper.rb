# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  config.global_fixtures = :codes
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

def mock_user
  @user = mock_model(User)
  User.stub!(:find_by_uid).and_return(@user)
  User.stub!(:current_user).and_return(@user)
  @user.stub!(:uid).and_return("utah")
  @user
end

def mock_event
  
  event = mock_model(Event)
  event_status = mock_model(Code)
  imported_from = mock_model(Code)
  event_case_status =mock_model(Code)
  outbreak_associated = mock_model(Code)
  investigation_LHD_status = mock_model(Code)
  hospitalized = mock_model(Code)
  died = mock_model(Code)
  pregnant = mock_model(Code)
  specimen_source = mock_model(Code)
  tested_at_uphl_yn = mock_model(Code)

  lab_result = mock_model(LabResult)
  disease_event = mock_model(DiseaseEvent)
  disease = mock_model(Disease)

  disease.stub!(:disease_id).and_return(1)
  disease.stub!(:disease_name).and_return("Bubonic,Plague")
    
  event_status.stub!(:code_description).and_return('Open')
  imported_from.stub!(:code_description).and_return('Utah')
  event_case_status.stub!(:code_description).and_return('Confirmed')
  outbreak_associated.stub!(:code_description).and_return('Yes')
  investigation_LHD_status.stub!(:code_description).and_return('Closed')
  hospitalized.stub!(:code_description).and_return('Yes')
  died.stub!(:code_description).and_return('No')
  pregnant.stub!(:code_description).and_return('No')
    
  disease_event.stub!(:disease_id).and_return(1)
  disease_event.stub!(:hospital_id).and_return(13)
  disease_event.stub!(:hospitalized).and_return(hospitalized)
  disease_event.stub!(:hospitalized_id).and_return(1401)
  disease_event.stub!(:died_id).and_return(1401)
  disease_event.stub!(:died).and_return(died)
  disease_event.stub!(:pregnant).and_return(pregnant)
  disease_event.stub!(:disease).and_return(disease)
  disease_event.stub!(:date_diagnosed).and_return("2008-02-15")
  disease_event.stub!(:disease_onset_date).and_return("2008-02-13")
  disease_event.stub!(:pregnant_id).and_return(1401)
  disease_event.stub!(:pregnancy_due_date).and_return("")
    
  specimen_source.stub!(:code_description).and_return('Tissue')
  tested_at_uphl_yn.stub!(:code_description).and_return('Yes')
    
  lab_result.stub!(:specimen_source_id).and_return(1501)
  lab_result.stub!(:specimen_source).and_return(specimen_source)
  lab_result.stub!(:lab_result_text).and_return("Positive")
  lab_result.stub!(:collection_date).and_return("2008-02-14")
  lab_result.stub!(:lab_test_date).and_return("2008-02-15")
    
  lab_result.stub!(:tested_at_uphl_yn_id).and_return(1401)
  lab_result.stub!(:tested_at_uphl_yn).and_return(tested_at_uphl_yn)
    
  event.stub!(:record_number).and_return("2008537081")
  event.stub!(:event_name).and_return('Test')
  event.stub!(:event_onset_date).and_return("2008-02-19")
  event.stub!(:disease).and_return(disease_event)
  event.stub!(:lab_result).and_return(lab_result)
  event.stub!(:event_status_id).and_return("1901")
  event.stub!(:event_status).and_return(event_status)
  event.stub!(:imported_from_id).and_return("2101")
  event.stub!(:imported_from).and_return(imported_from)
  event.stub!(:event_case_status_id).and_return(1801)
  event.stub!(:event_case_status).and_return(event_case_status)
  event.stub!(:outbreak_associated_id).and_return(1401)
  event.stub!(:outbreak_associated).and_return(outbreak_associated)
  event.stub!(:outbreak_name).and_return("Test Outbreak")
  event.stub!(:investigation_LHD_status_id).and_return(1701)
  event.stub!(:investigation_LHD_status).and_return(investigation_LHD_status)
  event.stub!(:investigation_started_date).and_return("2008-02-05")
  event.stub!(:investigation_completed_LHD_date).and_return("2008-02-08")
  event.stub!(:review_completed_UDOH_date).and_return("2008-02-11")
  event.stub!(:first_reported_PH_date).and_return("2008-02-07")
  event.stub!(:results_reported_to_clinician_date).and_return("2008-02-08")
  event.stub!(:MMWR_year).and_return("2008")
  event.stub!(:MMWR_week).and_return("7")
  event
end

def mock_person_entity
  person = mock_model(Person)
  person.stub!(:entity_id).and_return("1")
  person.stub!(:last_name).and_return("Marx")
  person.stub!(:first_name).and_return("Groucho")
  person.stub!(:middle_name).and_return("Julius")
  person.stub!(:birth_date).and_return(Date.parse('1902-10-2'))
  person.stub!(:date_of_death).and_return(Date.parse('1970-4-21'))
  person.stub!(:birth_gender_id).and_return(1)
  person.stub!(:ethnicity_id).and_return(101)
  person.stub!(:primary_language_id).and_return(301)
  person.stub!(:approximate_age_no_birthday).and_return(50)
  person.stub!(:food_handler_id).and_return(1401)
  person.stub!(:healthcare_worker_id).and_return(1401)
  person.stub!(:group_living_id).and_return(1401)
  person.stub!(:day_care_association_id).and_return(1401)
  person.stub!(:risk_factors).and_return("None")
  person.stub!(:risk_factors_notes).and_return("None")

  entities_location = mock_model(EntitiesLocation)
  entities_location.stub!(:entity_id).and_return("1")
  entities_location.stub!(:entity_location_type_id).and_return("1302")
  entities_location.stub!(:primary_yn_id).and_return("1402")

  address = mock_model(Address)
  address.stub!(:street_number).and_return("123")
  address.stub!(:street_name).and_return("Elm St.")
  address.stub!(:unit_number).and_return("99")
  address.stub!(:city).and_return("Provo")
  address.stub!(:state_id).and_return(1001)
  address.stub!(:postal_code).and_return("12345")
  address.stub!(:county_id).and_return(1101)

  phone = mock_model(Telephone)
  phone.stub!(:area_code).and_return("212")
  phone.stub!(:phone_number).and_return("5551212")
  phone.stub!(:extension).and_return("4444")

  entity = mock_model(Entity, :to_param => '1')
  entity.stub!(:entity_type).and_return('person')
  entity.stub!(:person).and_return(person)
  entity.stub!(:entities_location).and_return(entities_location)
  entity.stub!(:address).and_return(address)
  entity.stub!(:telephone).and_return(phone)
  entity.stub!(:race_ids).and_return([201])
  entity
end
