# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

require 'spec/autorun'
require 'spec/rails'
require 'spec/custom_matchers'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
 
# Load up factories
Dir.glob(File.expand_path(File.dirname(__FILE__) + "/../spec/factories/*.rb")) {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(CustomMatchers)
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
  config.global_fixtures = :codes, :external_codes
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  # 
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner

  config.after(:each) {
     User.current_user = nil
  }
end

# Bypass nested set logic to invalidate the provided form.
def invalidate_form(form)
  ActiveRecord::Base.connection.execute("update form_elements set parent_id = null where id = #{form.investigator_view_elements_container.id}")
end

# Bypass nested set logic to invalidate the provided tree's root
def invalidate_tree(tree_root)
  ActiveRecord::Base.connection.execute("update form_elements set rgt = 1 where id = #{tree_root.id}")
end

def mock_user
  @jurisdiction = mock_model(PlaceEntity)
  @place = mock_model(Place)

  @user = mock_model(User)
  User.stub!(:find_by_uid).and_return(@user)
  User.stub!(:current_user).and_return(@user)
  @user.stub!(:id).and_return(1)
  @user.stub!(:uid).and_return("utah")
  @user.stub!(:user_name).and_return("default_user")
  @user.stub!(:first_name).and_return("Johnny")
  @user.stub!(:last_name).and_return("Johnson")
  @user.stub!(:given_name).and_return("Johnny")
  @user.stub!(:initials).and_return("JJ")
  @user.stub!(:generational_qualifer).and_return("")
  @user.stub!(:is_admin?).and_return(true)
  @user.stub!(:jurisdictions_for_privilege).and_return([@place])
  @user.stub!(:is_entitled_to?).and_return(true)
  @user.stub!(:event_view_settings).and_return(nil)
  @user.stub!(:best_name).and_return("Johnny Johnson")
  @user.stub!(:disabled?).and_return(false)

  @role_membership = mock_model(RoleMembership)
  @role = mock_model(Role)
  
  @role.stub!(:role_name).and_return("administrator")
  @role_membership.stub!(:role).and_return(@role)
  @role_membership.stub!(:jurisdiction).and_return(@jurisdiction)
  @role_membership.stub!(:role_id).and_return("1")
  @role_membership.stub!(:jurisdiction_id).and_return("75")
  @role_membership.stub!(:should_destroy).and_return(0)
  @role_membership.stub!(:is_admin?).and_return(true)
  @role_membership.stub!(:id=).and_return(1)
  @jurisdiction.stub!(:places).and_return([@place])
  @jurisdiction.stub!(:place).and_return(@place)
  @place.stub!(:name).and_return("Southeastern District")
  @place.stub!(:entity_id).and_return("1")
  
  @user.stub!(:role_memberships).and_return([@role_membership])
  @user.stub!(:admin_jurisdiction_ids).and_return([75])
  @user.stub!(:is_entitled_to_in?).and_return(true)
  @user.stub!(:new_record?).and_return(false)
  
  @user
end

def mock_event
  
  event = mock_model(MorbidityEvent)
  person = mock_person_entity
  
  imported_from = mock_model(ExternalCode)
  state_case_status =mock_model(ExternalCode)
  lhd_case_status =mock_model(ExternalCode)
  outbreak_associated = mock_model(Code)
  hospitalized = mock_model(ExternalCode)
  died = mock_model(ExternalCode)
  pregnant = mock_model(ExternalCode)
  specimen_source = mock_model(ExternalCode)
  specimen_sent_to_state = mock_model(ExternalCode)
  
  disease_event = mock_model(DiseaseEvent)
  disease = mock_model(Disease)
  lab_result = mock_model(LabResult)
  answer = mock_model(Answer)
  
  jurisdiction = mock_model(Jurisdiction)
  interested_party = mock_model(InterestedParty)
  lab = mock_model(Lab)
  diagnostic = mock_model(DiagnosticFacility)
  hospital = mock_model(HospitalizationFacility)

  disease.stub!(:disease_id).and_return(1)
  disease.stub!(:disease_name).and_return("Bubonic,Plague")
  disease.stub!(:treatment_lead_in).and_return("")
  disease.stub!(:place_lead_in).and_return("")
  disease.stub!(:contact_lead_in).and_return("")
    
  imported_from.stub!(:code_description).and_return('Utah')
  state_case_status.stub!(:code_description).and_return('Confirmed')
  lhd_case_status.stub!(:code_description).and_return('Confirmed')
  outbreak_associated.stub!(:code_description).and_return('Yes')
  hospitalized.stub!(:code_description).and_return('Yes')
  died.stub!(:code_description).and_return('No')
  pregnant.stub!(:code_description).and_return('No')
  
  jurisdiction.stub!(:secondary_entity_id).and_return(75)

  interested_party.stub!(:primary_entity).and_return(1)
  interested_party.stub!(:person_entity).and_return(person)
   
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
  specimen_sent_to_state.stub!(:code_description).and_return('Yes')
    
  lab_result.stub!(:specimen_source_id).and_return(1501)
  lab_result.stub!(:specimen_source).and_return(specimen_source)
  lab_result.stub!(:collection_date).and_return("2008-02-14")
  lab_result.stub!(:lab_test_date).and_return("2008-02-15")
    
  lab_result.stub!(:specimen_sent_to_state_id).and_return(1401)
  lab_result.stub!(:specimen_sent_to_state).and_return(specimen_sent_to_state)
  
  event.stub!(:all_jurisdictions).and_return([jurisdiction])
  event.stub!(:labs).and_return([lab])
  event.stub!(:diagnosing_health_facilities).and_return([diagnostic])
  event.stub!(:hospitalized_health_facilities).and_return([hospital])
  event.stub!(:jurisdiction).and_return(jurisdiction)
  event.stub!(:interested_party).and_return(interested_party)
  event.stub!(:record_number).and_return("2008537081")
  event.stub!(:event_name).and_return('Test')
  event.stub!(:event_onset_date).and_return("2008-02-19")
  event.stub!(:disease_event).and_return(disease_event)
  event.stub!(:lab_result).and_return(lab_result)
  event.stub!(:event_status).and_return("NEW")
  event.stub!(:imported_from_id).and_return("2101")
  event.stub!(:imported_from).and_return(imported_from)
  event.stub!(:state_case_status_id).and_return(1801)
  event.stub!(:lhd_case_status_id).and_return(1801)
  event.stub!(:state_case_status).and_return(state_case_status)
  event.stub!(:lhd_case_status).and_return(lhd_case_status)
  event.stub!(:outbreak_associated_id).and_return(1401)
  event.stub!(:outbreak_associated).and_return(outbreak_associated)
  event.stub!(:outbreak_name).and_return("Test Outbreak")
  event.stub!(:investigation_started_date).and_return("2008-02-05")
  event.stub!(:investigation_completed_LHD_date).and_return("2008-02-08")
  event.stub!(:review_completed_by_state_date).and_return("2008-02-11")
  event.stub!(:first_reported_PH_date).and_return("2008-02-07")
  event.stub!(:results_reported_to_clinician_date).and_return("2008-02-08")
  event.stub!(:MMWR_year).and_return("2008")
  event.stub!(:MMWR_week).and_return("7")
  event.stub!(:answers).and_return([answer])
  event.stub!(:form_references).and_return([])
  event.stub!(:under_investigation?).and_return(true)
  event.stub!(:interested_party=)
  event.stub!(:get_investigation_forms).and_return(nil)
  event.stub!(:safe_call_chain).with(:disease_event, :disease, :disease_name).and_return("Bubonic,Plague")
  event.stub!(:deleted_at).and_return(nil)
  event
end

def mock_person_entity
  person = mock_model(Person, :errors => stub("errors", :count => 0, :null_object => true))
  person.stub!(:entity_id).and_return("1")
  person.stub!(:last_name).and_return("Marx")
  person.stub!(:first_name).and_return("Groucho")
  person.stub!(:middle_name).and_return("Julius")
  person.stub!(:birth_date).and_return(Date.parse('1902-10-2'))
  person.stub!(:date_of_death).and_return(Date.parse('1970-4-21'))
  person.stub!(:birth_gender_id).and_return(1)
  person.stub!(:birth_gender).and_return(nil)
  person.stub!(:ethnicity_id).and_return(101)
  person.stub!(:primary_language_id).and_return(301)
  person.stub!(:approximate_age_no_birthday).and_return(50)
  person.stub!(:food_handler_id).and_return(1401)
  person.stub!(:healthcare_worker_id).and_return(1401)
  person.stub!(:group_living_id).and_return(1401)
  person.stub!(:day_care_association_id).and_return(1401)
  person.stub!(:risk_factors).and_return("None")
  person.stub!(:risk_factors_notes).and_return("None")

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
  entity.stub!(:entity_type).and_return('PersonEntity')
  entity.stub!(:person).and_return(person)
  entity.stub!(:address).and_return(address)
  entity.stub!(:telephone).and_return(phone)
  entity.stub!(:race_ids).and_return([201])
  entity
end

require File.join(File.dirname(__FILE__), 'rails_ext') unless ActiveRecord::Base.respond_to? :_find_by_sql_with_capture
